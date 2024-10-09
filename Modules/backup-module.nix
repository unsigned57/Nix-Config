{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.flexibleBackup;

  compressionMethods = {
    none = {
      extension = "";
      command = level: "${pkgs.rsync}/bin/rsync -a --delete";
    };
    zip = {
      extension = "zip";
      command = level: "${pkgs.zip}/bin/zip -r -${toString level}";
    };
    gzip = {
      extension = "tar.gz";
      command = level: "${pkgs.gnutar}/bin/tar czf - | ${pkgs.gzip}/bin/gzip -${toString level}";
    };
    bzip2 = {
      extension = "tar.bz2";
      command = level: "${pkgs.gnutar}/bin/tar cjf - | ${pkgs.bzip2}/bin/bzip2 -${toString level}";
    };
    xz = {
      extension = "tar.xz";
      command = level: "${pkgs.gnutar}/bin/tar cJf - | ${pkgs.xz}/bin/xz -${toString level}";
    };
    "7z" = {
      extension = "7z";
      command = level: "${pkgs.p7zip}/bin/7z a -mx=${toString level}";
    };
    zstd = {
      extension = "tar.zst";
      command = level: "${pkgs.gnutar}/bin/tar cf - | ${pkgs.zstd}/bin/zstd -${toString level}";
    };
    lz4 = {
      extension = "tar.lz4";
      command = level: "${pkgs.gnutar}/bin/tar cf - | ${pkgs.lz4}/bin/lz4 -${toString level}";
    };
  };

  compressionMethodType = types.enum ([ "auto" ] ++ builtins.attrNames compressionMethods);

  selectCompressionMethod =
    task:
    if task.compressionMethod == "auto" then
      let
        sourceSize = task.sourceSize or 0;
      in
      if sourceSize > 10 * 1024 * 1024 * 1024 then
        "zstd"
      else if sourceSize > 1 * 1024 * 1024 * 1024 then
        "gzip"
      else
        "zip"
    else
      task.compressionMethod;

  backupScript =
    task:
    let
      selectedMethod = selectCompressionMethod task;
      method = compressionMethods.${selectedMethod};
      ext = if selectedMethod == "none" then "" else ".${method.extension}";
      compressCmd =
        if selectedMethod == "none" then
          if task.incremental then
            "${method.command task.compressionLevel} --link-dest=$DEST_DIR/${task.name}_previous $SOURCE_DIR/ $DEST_DIR/${task.name}_$TIMESTAMP/"
          else
            "${method.command task.compressionLevel} $SOURCE_DIR/ $DEST_DIR/${task.name}_$TIMESTAMP/"
        else if selectedMethod == "zip" || selectedMethod == "7z" then
          "${method.command task.compressionLevel} $DEST_DIR/${task.name}_$TIMESTAMP$ext $SOURCE_DIR"
        else
          "${pkgs.gnutar}/bin/tar cf - -C $SOURCE_DIR . | ${method.command task.compressionLevel} > $DEST_DIR/${task.name}_$TIMESTAMP$ext";
    in
    pkgs.writeShellScript "backup-${task.name}.sh" ''
      #!/usr/bin/env bash
      set -euo pipefail

      TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
      SOURCE_DIR="${task.sourceDir}"
      DEST_DIR="${task.destDir}"

      # Ensure source directory exists
      if [[ ! -d "$SOURCE_DIR" ]]; then
        echo "Error: Source directory $SOURCE_DIR does not exist" >&2
        exit 1
      fi

      # Create destination directory if it doesn't exist
      mkdir -p "$DEST_DIR"

      ${optionalString (selectedMethod == "none" && task.incremental) ''
        # Update the previous backup link
        if [[ -L "$DEST_DIR/${task.name}_previous" ]]; then
          rm "$DEST_DIR/${task.name}_previous"
        fi
        latest=$(ls -td "$DEST_DIR/${task.name}"_*/ | head -n1)
        if [[ -n "$latest" ]]; then
          ln -s "$latest" "$DEST_DIR/${task.name}_previous"
        fi
      ''}

      # Perform the backup
      ${compressCmd}

      if [[ $? -eq 0 ]]; then
        echo "Backup successful for ${task.name}: ${task.name}_$TIMESTAMP$ext"
        ${
          optionalString (selectedMethod == "none" && task.incremental) ''
            # Update the previous backup link after successful backup
            rm -f "$DEST_DIR/${task.name}_previous"
            ln -s "$DEST_DIR/${task.name}_$TIMESTAMP/" "$DEST_DIR/${task.name}_previous"
          ''
        }
        # Clean up old backups
        ls -td "$DEST_DIR/${task.name}"_* | tail -n +${
          toString (task.versionsToKeep + 1)
        } | xargs -r rm -rf
        echo "Cleaned up old backups for ${task.name}, keeping ${toString task.versionsToKeep} versions"
      else
        echo "Backup failed for ${task.name}" >&2
        exit 1
      fi
    '';

  mainBackupScript = pkgs.writeShellScript "main-backup.sh" ''
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Starting parallel backups with concurrency: ${toString cfg.concurrency}"

    # Use GNU Parallel to run backup tasks in parallel
    ${pkgs.parallel}/bin/parallel -j ${toString cfg.concurrency} {} ::: \
    ${concatStringsSep " " (map (task: "${backupScript task}") cfg.tasks)}

    echo "All backup tasks completed"
  '';

  taskModule = types.submodule {
    options = {
      name = mkOption {
        type = types.strMatching "[a-zA-Z0-9_-]+";
        description = "Name of the backup task (alphanumeric, underscore, and hyphen only)";
      };
      sourceDir = mkOption {
        type = types.path;
        description = "Source directory to backup";
      };
      destDir = mkOption {
        type = types.path;
        description = "Destination directory for backups";
      };
      compressionMethod = mkOption {
        type = compressionMethodType;
        default = "auto";
        description = "Compression method to use (auto, none, zip, gzip, bzip2, xz, 7z, zstd, lz4)";
      };
      compressionLevel = mkOption {
        type = types.ints.between 1 22;
        default = 6;
        description = "Compression level (1-9 for most methods, 1-22 for zstd)";
      };
      versionsToKeep = mkOption {
        type = types.ints.positive;
        default = 3;
        description = "Number of backup versions to keep";
      };
      user = mkOption {
        type = types.str;
        default = "root";
        description = "User to run this specific backup task";
      };
      group = mkOption {
        type = types.str;
        default = "root";
        description = "Group to run this specific backup task";
      };
      interval = mkOption {
        type = types.str;
        default = "daily";
        description = "Backup interval for this task (systemd calendar event syntax)";
      };
      incremental = mkOption {
        type = types.bool;
        default = false;
        description = "Enable incremental backups (only for 'none' compression method)";
      };
      sourceSize = mkOption {
        type = types.nullOr types.ints.unsigned;
        default = null;
        description = "Estimated size of the source directory in bytes (used for auto compression method selection)";
      };
    };
  };

in
{
  options.services.flexibleBackup = {
    enable = mkEnableOption "Flexible backup service";

    concurrency = mkOption {
      type = types.ints.positive;
      default = 2;
      description = "Number of backup tasks to run in parallel";
    };

    tasks = mkOption {
      type = types.listOf taskModule;
      default = [ ];
      description = "List of backup tasks";
    };

    notifyOnSuccess = mkOption {
      type = types.bool;
      default = false;
      description = "Send a notification on successful backup completion";
    };

    notifyOnFailure = mkOption {
      type = types.bool;
      default = true;
      description = "Send a notification on backup failure";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.tasks != [ ];
        message = "At least one backup task must be configured";
      }
    ];

    systemd = {
      services =
        {
          flexible-backup-main = {
            description = "Perform all flexible backups in parallel";
            path = with pkgs; [
              coreutils
              gnutar
            ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${mainBackupScript}";
              Nice = 10;
              IOSchedulingClass = "best-effort";
              IOSchedulingPriority = 7;
            };
          };
        }
        // listToAttrs (
          map (
            task:
            nameValuePair "flexible-backup-${task.name}" {
              description = "Perform flexible backup for ${task.name}";
              path = with pkgs; [
                coreutils
                gnutar
              ];
              serviceConfig = {
                Type = "oneshot";
                User = task.user;
                Group = task.group;
                ExecStart = "${backupScript task}";
                Nice = 10;
                IOSchedulingClass = "best-effort";
                IOSchedulingPriority = 7;
                PrivateTmp = true;
                ProtectSystem = "strict";
                ProtectHome = true;
                ReadWritePaths = [ task.destDir ];
                CapabilityBoundingSet = "";
                NoNewPrivileges = true;
              };
            }
          ) cfg.tasks
        );

      timers = {
        flexible-backup-main = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "daily";
            Persistent = true;
            RandomizedDelaySec = "1h";
          };
        };
      };
    };
  };
}
