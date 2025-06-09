# DuckDNS dynamic DNS service configuration

{ config, lib, pkgs, ... }:

{
  services.duckdns = {
    enable = true;
    domain = "fabioavf";
    token = "49d0657d-81f9-44d9-8995-98b484ab4272";
  };
}