# DuckDNS dynamic DNS service configuration
# Desktop-only service (fabio-nixos)

{ config, lib, pkgs, ... }:

lib.mkIf (config.networking.hostName == "fabio-nixos") {
  # Sops secret for DuckDNS token
  sops.secrets.duckdns_token = {
    sopsFile = ../../secrets/secrets.yaml;
    owner = "nobody";
    group = "nogroup";
    mode = "0400";
  };

  # Custom DuckDNS systemd service
  systemd.services.duckdns = {
    description = "DuckDNS Dynamic DNS updater";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      User = "nobody";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.curl}/bin/curl -s \"https://www.duckdns.org/update?domains=fabioavf&token=$(cat ${config.sops.secrets.duckdns_token.path})&ip=\"'";
      LoadCredential = "duckdns_token:${config.sops.secrets.duckdns_token.path}";
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