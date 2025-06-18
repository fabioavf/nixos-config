# /etc/nixos/system/programs/default.nix
# System-wide program configurations

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./fonts.nix
    ./audio.nix
    ./gaming.nix
    ./theming.nix
  ];

  programs = {
    # make HM-managed GTK stuff work
    dconf.enable = true;
    seahorse.enable = true;
    adb.enable = true;

    zsh = {
      enable = true;

      # Enable system-wide zsh plugins for all users
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];

  # Set zsh as default shell
  users.defaultUserShell = pkgs.zsh;

  services.udev.packages = [ pkgs.android-udev-rules ];
}
