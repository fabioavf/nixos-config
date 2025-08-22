# /etc/nixos/home/media/default.nix
# Media applications and tools

{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Media packages for all devices
  home.packages = with pkgs; [
    # ========================================
    # Music and Audio
    # ========================================
    # (spotify.overrideAttrs (oldAttrs: {
    #   postFixup = (oldAttrs.postFixup or "") + ''
    #     wrapProgram $out/bin/spotify \
    #       --add-flags "--force-device-scale-factor=1.5"
    #   '';
    # }))
    spotifywm
    youtube-music

    # Media player control
    playerctl # Media player control

    # Audio control
    pavucontrol # Audio control GUI
  ];
}
