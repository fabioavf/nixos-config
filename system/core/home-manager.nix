# /etc/nixos/system/core/home-manager.nix
# Home Manager integration for user configuration

{
  inputs,
  ...
}:

{
  # Home Manager configuration - users are configured in flake.nix
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      # Pass inputs for niri-flake and other flake inputs
      inherit inputs;
    };
  };
}
