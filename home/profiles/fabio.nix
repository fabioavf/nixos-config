# /etc/nixos/home/profiles/fabio.nix
# Home Manager configuration for user fabio

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ../services/niri
    ../terminal/default.nix
    ../media/default.nix
  ];

  # Home Manager needs to know about the user
  home.username = "fabio";
  home.homeDirectory = "/home/fabio";

  # Programs and user-specific configurations
  programs = {
    # Shell configuration
    zsh = {
      enable = true;
      
      # Oh My Zsh configuration
      oh-my-zsh = {
        enable = true;
        plugins = [ 
          "git" 
          "history" 
          "sudo" 
          "docker" 
          "extract" 
          "colored-man-pages"
          "z"
          "fzf"
        ];
        theme = "robbyrussell";
      };
      
      # User-specific aliases (conditional based on hostname)
      shellAliases = {
        # NixOS shortcuts (common)
        nrs = "sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)";
        nrt = "sudo nixos-rebuild test --flake /etc/nixos#$(hostname)";
        nrb = "sudo nixos-rebuild boot --flake /etc/nixos#$(hostname)";
        nru = "sudo nix flake update /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)";
        
        # Directory shortcuts (common)
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        
        # Enhanced ls (common)
        ll = "ls -alFh";
        la = "ls -A";
        l = "ls -CF";
        
        # Git shortcuts (common)
        gs = "git status";
        ga = "git add";
        gc = "git commit";
        gco = "git checkout";
        gp = "git push";
        gl = "git pull";
        gd = "git diff";
        
        # NixOS config editing shortcuts
        nixedit = "sudo chown -R $USER /etc/nixos && zeditor /etc/nixos";
        nixdone = "sudo chown -R root /etc/nixos";
        nixopen = "zeditor /etc/nixos";
      };
      
      # Shell initialization  
      initContent = ''
        # Enable starship prompt
        eval "$(starship init zsh)"
        
        # Enable pay-respects (modern thefuck alternative)
        if command -v pay-respects >/dev/null 2>&1; then
          alias fuck='pay-respects'
        fi

        # Auto-start Niri on TTY1
        if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
          exec niri
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
        
        # Additional zsh options for better UX
        setopt auto_cd              # cd by typing directory name
        setopt correct              # command correction
        setopt complete_in_word     # complete from both ends of word
        setopt always_to_end        # move cursor to end if word had one match
        setopt auto_menu            # show completion menu on tab
        setopt auto_list            # automatically list choices on ambiguous completion
        setopt complete_aliases     # complete aliases
        
        # Case insensitive completion
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
        
        # Colored completion (different colors for dirs/files/etc)
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        
        # Use fzf for history search and interactive cd
        if command -v fzf >/dev/null 2>&1; then
          source <(fzf --zsh)
          
          # Interactive cd with fzf
          fcd() {
            local dir
            dir=$(find ''${1:-.} -type d 2>/dev/null | fzf --preview 'ls -la {}' --height 40%)
            if [[ -n $dir ]]; then
              cd "$dir"
            fi
          }
          
          # Fuzzy find and edit files
          fe() {
            local file
            file=$(fzf --preview 'bat --color=always --style=numbers {}' --height 60%)
            if [[ -n $file ]]; then
              ''${EDITOR:-vim} "$file"
            fi
          }
        fi
      '';
    };

    # Git configuration
    git = {
      enable = true;
      userName = "fabioavf";
      userEmail = "amorelli.ff@gmail.com";
      
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = false;
        core.editor = "vim";
      };
    };

    # Starship prompt
    starship = {
      enable = true;
      # You can add custom starship configuration here
    };

    # Bat (better cat)
    bat = {
      enable = true;
      config = {
        theme = "TwoDark";
        style = "numbers,changes,header";
      };
    };

    # Fzf (fuzzy finder)
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  # User packages (alternatives to system packages)
  home.packages = with pkgs; [
    # These are now user-specific
    pay-respects      # Command correction
    zsh-completions   # Additional completions
  ];

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Home Manager version
  home.stateVersion = "25.05";
}
