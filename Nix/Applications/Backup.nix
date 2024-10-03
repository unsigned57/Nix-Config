{ config, pkgs, ... }:

{
  services = {
    syncthing = {
      enable = true;
    };
  };

  systemd = {
    services.compress-and-move = {
      description = "Compress directory and move to destination, then delete the previous backup";
      script = ''
        #!/bin/sh
        SOURCE_DIR="/home/ephemeral/Documents/Obsidian"
        DEST_DIR="/run/media/ephemeral/linux/Backup"
        DIRNAME=$(basename "$SOURCE_DIR")
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        BACKUP_PREFIX="$DIRNAME"

        ${pkgs.zip}/bin/zip -r "$DEST_DIR/''${BACKUP_PREFIX}_$TIMESTAMP.zip" "$SOURCE_DIR"

        if [ $? -eq 0 ]; then
          echo "Compression successful: ''${BACKUP_PREFIX}_$TIMESTAMP.zip"

          previous_backup=$(ls -t "$DEST_DIR/''${BACKUP_PREFIX}"_*.zip 2>/dev/null | sed -n '2p')
          if [ -n "$previous_backup" ]; then
            rm "$previous_backup"
            echo "Deleted previous backup: $previous_backup"
          else
            echo "No previous backup found to delete"
          fi
        else
          echo "Compression failed" >&2
          exit 1
        fi
      '';

      serviceConfig = {
        Type = "oneshot";
        User = "ephemeral";
      };
    };

    timers.compress-and-move = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "10min";
        OnUnitActiveSec = "2d";
        Persistent = true;
      };
    };
  };
}