{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.flexibleBackup;

  # 定义备份脚本
  backupScript = pkgs.writeShellScript "backup.sh" ''
    #!/bin/sh
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

    ${builtins.concatStringsSep "\n" (map (task: ''
      # Backup task: ${task.name}
      SOURCE_DIR="${task.sourceDir}"
      DEST_DIR="${task.destDir}/${if task.compress then "Compressed" else "Uncompressed"}/${task.name}"
      BACKUP_PREFIX="$(basename "$SOURCE_DIR")"

      mkdir -p "$DEST_DIR"

      if ${if task.compress then "true" else "false"}; then
        case "${task.compressionMethod}" in
          "zip")
            ${pkgs.zip}/bin/zip -r -${toString task.compressionLevel} "$DEST_DIR/''${BACKUP_PREFIX}_$TIMESTAMP.zip" "$SOURCE_DIR"
            ;;
          "gzip")
            ${pkgs.gzip}/bin/gzip -${toString task.compressionLevel} < "$SOURCE_DIR" > "$DEST_DIR/''${BACKUP_PREFIX}_$TIMESTAMP.tar.gz"
            ;;
          "bzip2")
            ${pkgs.bzip2}/bin/bzip2 -${toString task.compressionLevel} < "$SOURCE_DIR" > "$DEST_DIR/''${BACKUP_PREFIX}_$TIMESTAMP.tar.bz2"
            ;;
          "xz")
            ${pkgs.xz}/bin/xz -${toString task.compressionLevel} < "$SOURCE_DIR" > "$DEST_DIR/''${BACKUP_PREFIX}_$TIMESTAMP.tar.xz"
            ;;
          "zstd")
            ${pkgs.zstd}/bin/zstd -${toString task.compressionLevel} "$SOURCE_DIR" -o "$DEST_DIR/''${BACKUP_PREFIX}_$TIMESTAMP.tar.zst"
            ;;
          *)
            echo "Unsupported compression method: ${task.compressionMethod}" >&2
            exit 1
            ;;
        esac

        if [ $? -eq 0 ]; then
          echo "${task.compressionMethod} compressed backup successful for ${task.name}: ''${BACKUP_PREFIX}_$TIMESTAMP"
          ls -t "$DEST_DIR/''${BACKUP_PREFIX}"_* | tail -n +3 | xargs -r rm
          echo "Cleaned up old compressed backups for ${task.name}"
        else
          echo "${task.compressionMethod} compressed backup failed for ${task.name}" >&2
        fi
      else
        ${pkgs.rsync}/bin/rsync -av --delete "$SOURCE_DIR" "$DEST_DIR/''${BACKUP_PREFIX}_$TIMESTAMP"
        if [ $? -eq 0 ]; then
          echo "Uncompressed backup successful for ${task.name}: ''${BACKUP_PREFIX}_$TIMESTAMP"
          ls -td "$DEST_DIR/''${BACKUP_PREFIX}"_* | tail -n +3 | xargs -r rm -rf
          echo "Cleaned up old uncompressed backups for ${task.name}"
        else
          echo "Uncompressed backup failed for ${task.name}" >&2
        fi
      fi
    '') cfg.tasks)}
  '';

in {
  options.services.flexibleBackup = {
    enable = mkEnableOption "Flexible backup service";

    tasks = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Name of the backup task";
          };
          sourceDir = mkOption {
            type = types.path;
            description = "Source directory to backup";
          };
          destDir = mkOption {
            type = types.path;
            description = "Destination directory for backups";
          };
          compress = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to compress the backup";
          };
          compressionMethod = mkOption {
            type = types.enum [ "zip" "gzip" "bzip2" "xz" "zstd" ];
            default = "zip";
            description = "Compression method to use (zip, gzip, bzip2, xz, zstd)";
          };
          compressionLevel = mkOption {
            type = types.int;
            default = 5;
            description = "Compression level (1 for faster, 9 for higher compression)";
          };
        };
      });
      default = [];
      description = "List of backup tasks";
    };

    interval = mkOption {
      type = types.str;
      default = "2d";
      description = "Backup interval (systemd time format)";
    };

    user = mkOption {
      type = types.str;
      default = "root";
      description = "User to run the backup service";
    };
  };

  config = mkIf cfg.enable {
    systemd = {
      services.flexible-backup = {
        description = "Perform flexible backups based on predefined tasks";
        serviceConfig = {
          Type = "oneshot";
          User = cfg.user;
          ExecStart = "${backupScript}";
        };
      };

      timers.flexible-backup = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "10min";
          OnUnitActiveSec = cfg.interval;
          Persistent = true;
        };
      };
    };
  };
}

