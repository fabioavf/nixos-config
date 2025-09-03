# Custom XKB configuration for cedilla support
# This creates a variant that uses cedilla instead of acute accent for c

{ pkgs, lib, ... }:

let
  # Create a proper XKB symbols file that only modifies compose behavior
  cedillaSymbolsFile = pkgs.writeText "us-cedilla" ''
    // US layout with cedilla variant
    // This is a minimal variant that redirects acute+c to cedilla

    partial alphanumeric_keys modifier_keys
    xkb_symbols "intl-cedilla" {
        include "us(intl)"
        name[Group1]= "English (US, international with cedilla)";

        // Don't override key mappings, just include the base layout
        // The cedilla behavior will be handled by compose sequences

        include "compose(ralt)"
        include "level3(ralt_switch)"
    };
  '';

  # Create a compose file that overrides acute+c behavior
  cedillaCompose = pkgs.writeText "cedilla-compose" ''
    # Custom compose sequences for cedilla
    # Override the default acute accent behavior for c
    <dead_acute> <c> : "ç"
    <dead_acute> <C> : "Ç"
    <apostrophe> <c> : "ç"
    <apostrophe> <C> : "Ç"
  '';
in
{
  # Configure the custom layout
  services.xserver.xkb = {
    extraLayouts.us-cedilla = {
      description = "US International with cedilla";
      languages = [ "eng" ];
      symbolsFile = cedillaSymbolsFile;
    };
  };

  # Install custom compose sequences
  environment.etc."X11/locale/en_US.UTF-8/Compose".source = lib.mkForce cedillaCompose;
}
