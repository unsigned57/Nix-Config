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
            id = "45FRUN5-UQJ6ZMO-6ZD5AVC-5XCFSRT-NC36XLU-5WNFRE7-DWLEYMR-7ZUR4AR";
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

    flexibleBackup = {
      enable = true;
      tasks = [
        {
          name = "obsidian";
          sourceDir = "/home/ephemeral/Documents/Obsidian";
          destDir = "/run/media/ephemeral/linux/Backup";
          compress = true;
          compressionMethod = "zstd";
          compressionLevel = 3;
        }
        {
          name = "documents";
          sourceDir = "/home/ephemeral/Documents";
          destDir = "/run/media/ephemeral/external_drive/Backup";
          compress = true;
          compressionMethod = "xz";
          compressionLevel = 9;
        }
      ];
      interval = "2d";
      user = "ephemeral";
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
