# /etc/nixos/modules/development/shell.nix
# Shell configuration with proper oh-my-zsh setup

{ config, lib, pkgs, ... }:

{
  # Enable zsh system-wide
  programs.zsh = {
    enable = true;
    
    # Oh My Zsh configuration
    ohMyZsh = {
      enable = true;
      plugins = [ 
        "git" 
        "history" 
        "sudo" 
        "docker" 
        "extract" 
        "colored-man-pages" 
      ];
      theme = "robbyrussell";  # Simple theme, change as needed
    };
    
    # System-wide aliases
    shellAliases = {
      # NixOS shortcuts
      nrs = "sudo nixos-rebuild switch --flake /etc/nixos#fabio-nixos";
      nrt = "sudo nixos-rebuild test --flake /etc/nixos#fabio-nixos";
      nrb = "sudo nixos-rebuild boot --flake /etc/nixos#fabio-nixos";
      nru = "sudo nix flake update /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos#fabio-nixos";
      
      # Directory shortcuts
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      
      # Enhanced ls
      ll = "ls -alFh";
      la = "ls -A";
      l = "ls -CF";
      
      # Git shortcuts
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
    };
    
    # Additional shell initialization
    shellInit = ''
      # Enable starship prompt
      eval "$(starship init zsh)"

      # Auto-start Hyprland on TTY1
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
        exec Hyprland
      fi
      
      # Enhanced history settings
      HISTSIZE=50000
      SAVEHIST=10000
      setopt extended_history
      setopt hist_expire_dups_first
      setopt hist_ignore_dups
      setopt hist_ignore_space
      setopt hist_verify
      setopt inc_append_history
      setopt share_history
    '';
  };
  
  # Set zsh as default shell
  users.defaultUserShell = pkgs.zsh;
  
  # Shell packages
  environment.systemPackages = with pkgs; [
    starship           # Modern prompt
    bat               # Better cat
    fzf               # Fuzzy finder
  ];
}
