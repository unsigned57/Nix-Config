{ config, pkgs, ... }:

{
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

    tempus = {
      enable = true;
      tasks = {
        obsidian = {
          src = "/home/ephemeral/Documents/Obsidian";
          dst = "/run/media/ephemeral/linux/Backup";
          compress = "zip";
          keep = "10d";
          freq = "daily";
          user = "ephemeral";
          group = "users";
        };

        book = {
          src = "/home/ephemeral/Documents/Book";
          dst = "/run/media/ephemeral/win/";
          compress = "none";
          freq = "daily";
          user = "ephemeral";
          group = "users";
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
