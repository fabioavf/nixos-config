# /etc/nixos/system/programs/bluetooth.nix
# Bluetooth configuration with BlueZ

{
  pkgs,
  ...
}:

{
  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true; # Power up the default Bluetooth controller on boot
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true; # Enable experimental features for better codec support
      };
    };
  };

  # Enable Bluetooth management service
  services.blueman.enable = true;

  # Add Bluetooth tools
  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
    blueman
  ];

  # Enable PipeWire Bluetooth support (complement to audio.nix)
  services.pipewire = {
    wireplumber.extraConfig = {
      bluetoothEnhancements = {
        "wireplumber.settings" = {
          "bluetooth.autoswitch-to-headset-profile" = false;
        };
      };
    };
  };
}
