{ lib, pkgs, ... }:

{
  networking = {
    hostName = "ephemeral";
    useDHCP = lib.mkDefault true;
    nftables.enable = true;
    firewall = {
      package = pkgs.iptables-nftables-compat;
      allowedTCPPorts = [
        22
        53317
      ];
    };

    networkmanager = {
      enable = true;
    };
  };
}
