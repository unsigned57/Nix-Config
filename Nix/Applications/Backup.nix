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
          compressionMethod = "zip";
          compressionLevel = 6;
          versionsToKeep = 3;
          interval = "1d";
          user = "ephemeral";
          group = "users";
        }

        {
          name = "Book";
          sourceDir = "/home/ephemeral/Documents/Book";
          destDir = "/run/media/ephemeral/win/";
          compressionMethod = "none";
          versionsToKeep = 1;
          incremental = true;
          interval = "2d";
          user = "ephemeral";
          group = "users";
        }
      ];
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
