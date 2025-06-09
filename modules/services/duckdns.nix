# DuckDNS dynamic DNS service configuration

{ config, lib, pkgs, ... }:

{
  # Custom DuckDNS systemd service
  systemd.services.duckdns = {
    description = "DuckDNS Dynamic DNS updater";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      User = "nobody";
      ExecStart = "${pkgs.curl}/bin/curl -s 'https://www.duckdns.org/update?domains=fabioavf&token=49d0657d-81f9-44d9-8995-98b484ab4272&ip='";
    };
  };

  # Timer to run every 5 minutes
  systemd.timers.duckdns = {
    description = "DuckDNS update timer";
    wantedBy = [ "timers.target" ];
    
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "5min";
      Persistent = true;
    };
  };
}