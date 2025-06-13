# /etc/nixos/modules/environment/fonts.nix
# Font configuration

{ config, lib, pkgs, ... }:

{
  # Enable fontconfig and install fonts properly
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # Essential fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      
      # Programming fonts - Popular Nerd Fonts
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
      nerd-fonts.sauce-code-pro
      nerd-fonts.ubuntu-mono
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.inconsolata
      nerd-fonts.roboto-mono
      
      # UI fonts for quickshell
      ibm-plex                    # IBM Plex Sans
      material-symbols            # Material Symbols Rounded
    ];
  };
}
