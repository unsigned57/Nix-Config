{
  config,
  lib,
  pkgs,
  ...
}:

{
  preservation = {
    enable = true;

    preserveAt."/nix/persistent" = {

      directories = [
        "/etc/secureboot"
        "/etc/NetworkManager/system-connections"
        "/var/lib/bluetooth"
        "/var/lib/libvirt"
        "/var/lib/systemd"
        "/var/lib/waydroid"
        "/var/lib/flatpak"
        "/var/lib/NetworkManager"
        "/var/lib/chrony"
        "/var/lib/lxc"
        "/var/lib/lxd"
        "/var/lib/qemu"

        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
        {
          directory = "/var/log";
          inInitrd = true;
        }
        {
          directory = "/var/lib/private";
          mode = "0700";
        }
      ];

      files = [
        "/etc/daed/wing.db"
        # { file = "/etc/ssh/ssh_host_rsa_key"; mode = "0600"; }
        # { file = "/etc/ssh/ssh_host_ed25519_key"; mode = "0600"; }
        # { file = "/etc/ssh/ssh_host_rsa_key.pub"; mode = "0644"; }
        # { file = "/etc/ssh/ssh_host_ed25519_key.pub"; mode = "0644"; }
        {
          file = "/var/lib/systemd/random-seed";
          how = "symlink";
          inInitrd = true;
          configureParent = true;
        }
      ];

      users = {
        ephemeral = {
          directories = [
            {
              directory = ".ssh";
              mode = "0700";
            }
            "Documents"
            "Downloads"
            "Distrobox"
            "Desktop"
            "Public"
            "Pictures"
            "Videos"
            "Music"
            "Nix-Config"
            ".android"
            ".cache"
            {
              directory = ".local";
              user = "ephemeral";
            }
            {
              directory = ".config";
              user = "ephemeral";
            }
            ".steam"
            ".var"
          ];

          files = [
            ".bash_history"
          ];
        };
      };
    };
  };

  systemd = {
    services = {
      systemd-journal-flush = {
        before = [ "shutdown.target" ];
        conflicts = [ "shutdown.target" ];
      };

      nix-daemon = {
        environment = {
          TMPDIR = "/nix/Cache/nix";
        };
        serviceConfig = {
          CacheDirectory = "nix";
        };
      };
    };
  };

  boot.initrd.systemd = {
    enable = true;
    emergencyAccess = true;
  };
}
