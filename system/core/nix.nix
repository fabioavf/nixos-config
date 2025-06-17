# /etc/nixos/system/core/nix.nix
# Nix package manager configuration

{
  ...
}:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix = {
    # Enable flakes and new command-line tool
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
  };
}
