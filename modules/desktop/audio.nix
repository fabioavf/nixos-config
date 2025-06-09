# /etc/nixos/modules/desktop/audio.nix
# Audio configuration with PipeWire

{ config, lib, pkgs, ... }:

{
  # Disable PulseAudio
  services.pulseaudio.enable = false;
  
  # Enable rtkit for realtime audio scheduling
  security.rtkit.enable = true;
  
  # Configure PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  
  # Add audio tools
  environment.systemPackages = with pkgs; [
    pulseaudio  # For pactl command
    wireplumber # PipeWire session manager
    pipewire    # PipeWire tools including wpctl
  ];
}
