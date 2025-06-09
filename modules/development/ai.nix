# /etc/nixos/modules/development/ai.nix
# AI and Machine Learning tools with ROCm integration
# Designed to work with existing rocm.nix module

{ config, lib, pkgs, ... }:

{
  # Ollama - Local LLM inference server with ROCm support
  services.ollama = {
    enable = true;
    acceleration = "rocm";  # Use ROCm acceleration for AMD GPUs
    environmentVariables = {
      # ROCm configuration for Ollama
      HCC_AMDGPU_TARGET = "gfx1010";           # RX 5600/5700 XT target
      HSA_OVERRIDE_GFX_VERSION = "10.3.0";     # Compatibility override
      OLLAMA_DEBUG = "1";                      # Enable debug for troubleshooting
      
      # Memory management
      OLLAMA_MAX_VRAM = "7GB";                 # RX 5700 XT has 8GB, leave 1GB for system
      OLLAMA_NUM_PARALLEL = "1";               # Parallel requests
      
      # Performance optimizations
      AMD_DIRECT_DISPATCH = "1";
      HSA_ENABLE_SDMA = "0";
      ROC_ENABLE_PRE_VEGA = "1";
    };
    # Use the render group for GPU access
    group = "render";
  };

  # AI and ML packages
  environment.systemPackages = with pkgs; [
    # Local LLM tools
    ollama                         # Primary LLM server
    
    # Python ML stack (with ROCm support where available)
    python3                        # Python interpreter
    python3Packages.pip           # Package installer
    python3Packages.virtualenv    # Virtual environments
    python3Packages.numpy         # Numerical computing
    python3Packages.scipy         # Scientific computing
    python3Packages.matplotlib    # Plotting
    python3Packages.pandas        # Data analysis
    python3Packages.jupyter       # Jupyter notebooks
    python3Packages.ipython       # Interactive Python
    
    # AI development tools
    python3Packages.huggingface-hub  # Hugging Face model hub
    python3Packages.transformers     # Transformer models
    python3Packages.tokenizers       # Fast tokenizers
    python3Packages.datasets         # ML datasets
    
    # Image/Video AI tools
    python3Packages.pillow          # Image processing
    python3Packages.opencv4         # Computer vision
    
    # Model management
    git-lfs                        # Git Large File Storage for models
    
    # GPU monitoring for AI workloads
    nvtopPackages.amd             # GPU monitoring (already in gaming.nix but useful here)
    
    # Additional development tools
    python3Packages.requests       # HTTP client
    python3Packages.rich          # Rich terminal output
    python3Packages.typer         # CLI framework
    python3Packages.pydantic      # Data validation
    
    # Model conversion and optimization tools
    python3Packages.onnx          # ONNX model format
    python3Packages.protobuf      # Protocol buffers
  ];

  # Systemd service customizations for Ollama
  systemd.services.ollama = {
    # Ensure ROCm devices are available before starting
    after = [ "rocm-init.service" ];
    wants = [ "rocm-init.service" ];
    
    # Service configuration
    serviceConfig = {
      # Ensure proper group membership
      SupplementaryGroups = [ "render" ];
      
      # Resource limits for AI workloads
      LimitMEMLOCK = "infinity";
      LimitNOFILE = "1048576";
      
      # Working directory for models
      WorkingDirectory = "/var/lib/ollama";
      
      # Restart policy
      Restart = "on-failure";
      RestartSec = "5s";
    };
    
    # Environment setup
    environment = {
      # ROCm library paths
      LD_LIBRARY_PATH = lib.makeLibraryPath [
        pkgs.rocmPackages.clr
        pkgs.rocmPackages.rocm-runtime
        pkgs.rocmPackages.rocblas
        pkgs.rocmPackages.miopen
      ];
      
      # Additional ROCm environment
      ROCM_PATH = "${pkgs.rocmPackages.clr}";
      HIP_PATH = "${pkgs.rocmPackages.clr}";
    };
  };

  # Networking for Ollama API
  networking.firewall = {
    allowedTCPPorts = [ 
      11434  # Ollama API server
    ];
  };

  # Create directories for AI models and data
  systemd.tmpfiles.rules = [
    "d /var/lib/ollama 0755 ollama ollama -"
    "d /data/ai-models 0755 fabio users -"    # Using your /data partition
    "d /data/ai-datasets 0755 fabio users -"
    "d /data/ai-projects 0755 fabio users -"
  ];

  # Environment variables for AI development
  environment.sessionVariables = {
    # Ollama configuration
    OLLAMA_HOST = "127.0.0.1:11434";
    OLLAMA_MODELS = "/data/ai-models";         # Store models on data partition
    
    # Python AI environment
    PYTHONPATH = "$PYTHONPATH:/data/ai-projects";
    
    # Jupyter configuration
    JUPYTER_CONFIG_DIR = "$HOME/.jupyter";
    JUPYTER_DATA_DIR = "/data/ai-projects/jupyter";
    
    # Hugging Face cache (use data partition)
    HF_HOME = "/data/ai-models/huggingface";
    TRANSFORMERS_CACHE = "/data/ai-models/huggingface/transformers";
    
    # PyTorch ROCm (when available)
    PYTORCH_ROCM_ARCH = "gfx1010";           # Your GPU architecture
  };

  # Additional system configuration for AI workloads
  boot.kernel.sysctl = {
    # Increase shared memory for large models
    "kernel.shmmax" = 68719476736;           # 64GB
    "kernel.shmall" = 16777216;              # 64GB in pages
    
    # Increase memory map areas for AI applications (higher than gaming.nix)
    "vm.max_map_count" = lib.mkForce 2147483647;  # Large models need many memory maps
  };

  # Security considerations for AI services
  security.pam.loginLimits = [
    {
      domain = "ollama";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "ollama";
      item = "nofile";
      type = "-";
      value = "1048576";
    }
  ];

  # Ensure user has access to AI resources
  users.users.fabio.extraGroups = [ "ollama" ];
}
