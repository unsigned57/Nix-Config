{ config, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      rustic
    ];
  };

  services = {
    syncthing = {
      enable = true;
      user = "ephemeral";
      dataDir = "/home/ephemeral/Documents";
      configDir = "/home/ephemeral/Documents/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        devices = {
          "pixel" = {
            id = "ECY62PQ-VQVYNWN-SQRQ5D6-CRRNCGL-QXYJUWM-DB7JM6F-OLSQHW2-GU6GHQ2";
          };
        };
        folders = {
          "Music" = {
            path = "/home/ephemeral/Music";
            devices = [ "pixel" ];
            ignorePerms = false;
          };
        };
      };
    };
  };

  networking = {
    firewall = {
      allowedTCPPorts = [
        8384
        22000
      ];
      allowedUDPPorts = [
        22000
        21027
      ];
    };
  };
}
