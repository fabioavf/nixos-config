# /etc/nixos/modules/development/shell.nix
# Shell configuration with proper oh-my-zsh setup

{ config, lib, pkgs, ... }:

{
  # Enable zsh system-wide
  programs.zsh = {
    enable = true;
    
    # Enable zsh plugins
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    
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
        "z"
        "fzf"
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
      
      # Enable pay-respects (modern thefuck alternative)
      if command -v pay-respects >/dev/null 2>&1; then
        alias fuck='pay-respects'
      fi

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
  
  # Set zsh as default shell
  users.defaultUserShell = pkgs.zsh;
  
  # Shell packages
  environment.systemPackages = with pkgs; [
    starship           # Modern prompt
    bat               # Better cat
    fzf               # Fuzzy finder
    pay-respects      # Command correction (modern thefuck alternative)
    zsh-completions   # Additional completions
  ];
}
