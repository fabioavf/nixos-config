# /etc/nixos/modules/development/shell.nix
# System-wide shell configuration

{ config, lib, pkgs, ... }:

{
  # Enable zsh system-wide with basic features
  programs.zsh = {
    enable = true;
    
    # Enable system-wide zsh plugins for all users
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };
  
  # Set zsh as default shell
  users.defaultUserShell = pkgs.zsh;
  
  # System-wide shell packages
  environment.systemPackages = with pkgs; [
    starship           # Modern prompt
    bat               # Better cat
    fzf               # Fuzzy finder
    pay-respects      # Command correction (modern thefuck alternative)
    zsh-completions   # Additional completions
  ];
}
