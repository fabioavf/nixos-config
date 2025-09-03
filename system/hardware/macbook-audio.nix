# /etc/nixos/system/hardware/macbook-audio.nix
# MacBook-specific audio hardware configuration

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  # Configure the audio driver as an extra module
  boot.extraModulePackages = [ inputs.self.packages.x86_64-linux.snd-hda-macbookpro ];

  # Determine module to load based on kernel version
  boot.kernelModules =
    let
      kernelVersion = config.boot.kernelPackages.kernel.version;
      kernelVersionParts = builtins.splitVersion kernelVersion;
      major = lib.strings.toInt (builtins.elemAt kernelVersionParts 0);
      minor = lib.strings.toInt (builtins.elemAt kernelVersionParts 1);
    in
    if (major >= 6) || (major == 5 && minor >= 13) then
      [ "snd_hda_codec_cs8409" ] # Use underscores for module names
    else
      [ "snd_hda_codec_cirrus" ];

  # Clean modprobe configuration
  boot.extraModprobeConfig = ''
    # Basic HDA Intel configuration for MacBook Pro
    options snd_hda_intel model=mbp143 probe_mask=0x01

    # Hardware alias to ensure CS8409 chip uses our driver
    alias hdaudio:v10138409r*a01* snd_hda_codec_cs8409
  '';

  # Only blacklist generic driver, let our custom driver load
  boot.blacklistedKernelModules = [
    "snd_hda_codec_generic" # Block generic fallback driver
  ];

  # Activation script to ensure proper module loading
  system.activationScripts.cs8409Audio = ''
    # Update module dependencies
    ${pkgs.kmod}/bin/depmod -a 2>/dev/null || true

    # Try to unload generic driver if loaded
    ${pkgs.kmod}/bin/modprobe -r snd_hda_codec_generic 2>/dev/null || true
  '';
}
