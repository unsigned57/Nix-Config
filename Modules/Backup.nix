{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.tempus;

  backupTask = types.submodule {
    options = {
      src = mkOption {
        type = types.str;
        example = "/path/to/source";
        description = "Source directory to be backed up.";
      };

      dst = mkOption {
        type = types.str;
        example = "/path/to/destination";
        description = "Destination directory for backups.";
      };

      compress = mkOption {
        type = types.enum [
          "none"
          "zip"
          "rar"
          "7z"
          "zstd"
        ];
        default = "none";
        description = "Compression format for backups.";
      };

      keep = mkOption {
        type = types.str;
        default = "7d";
        example = "30d";
        description = "Retention period for backups (e.g., '7d' for 7 days).";
      };

      freq = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "daily";
        description = "Backup frequency (null to disable scheduling).";
      };

      user = mkOption {
        type = types.str;
        default = "root";
        example = "backup-user";
        description = "User under which the backup task will run.";
      };

      group = mkOption {
        type = types.str;
        default = "root";
        example = "backup-group";
        description = "Group under which the backup task will run.";
      };

      createUser = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to create a new system user for this task.";
      };
    };
  };

in
{
  options.services.tempus = {
    enable = mkEnableOption "Tempus backup service";

    tasks = mkOption {
      type = types.attrsOf backupTask;
      default = { };
      description = "Attribute set of Tempus backup tasks.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services = mapAttrs' (
      name: task:
      nameValuePair "tempus-${name}" {
        description = "Tempus backup service for ${name}";
        script =
          let
            compressCmd =
              if task.compress == "none" then "" else "${pkgs.${task.compress}}/bin/${task.compress}";
            backupScript = pkgs.writeScript "tempus-${name}.sh" ''
              #!${pkgs.bash}/bin/bash
              set -euo pipefail

              src="${task.src}"
              dst="${task.dst}"
              keep="${task.keep}"

              timestamp=$(date +%Y%m%d_%H%M%S)

              if [[ "${task.compress}" != "none" ]]; then
                ${compressCmd} "$dst/${name}_$timestamp.${task.compress}" "$src"
              else
                ${pkgs.rsync}/bin/rsync -a --delete "$src/" "$dst/${name}_$timestamp/"
              fi

              # Clean up old backups
              ${pkgs.findutils}/bin/find "$dst" -name "${name}_*" -type d -mtime +''${keep%d} -exec rm -rf {} +
            '';
          in
          "${backupScript}";
        serviceConfig = {
          Type = "oneshot";
          User = task.user;
          Group = task.group;
          ReadOnlyPaths = [ task.src ];
          ReadWritePaths = [ task.dst ];
        };
      }
    ) cfg.tasks;

    systemd.timers = mapAttrs' (
      name: task:
      nameValuePair "tempus-${name}" (
        mkIf (task.freq != null) {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = task.freq;
            Persistent = true;
          };
        }
      )
    ) cfg.tasks;

    # Create users only if createUser is true
    users.users = mkMerge (
      mapAttrsToList (
        name: task:
        optionalAttrs (task.user != "root" && task.createUser) {
          ${task.user} = {
            isSystemUser = true;
            group = task.group;
            description = "Tempus backup user for ${name}";
          };
        }
      ) cfg.tasks
    );

    # Create groups for new users
    users.groups = mkMerge (
      mapAttrsToList (
        name: task:
        optionalAttrs (task.group != "root" && task.createUser) {
          ${task.group} = { };
        }
      ) cfg.tasks
    );

    # Assert that users exist if not creating them
    assertions = mapAttrsToList (name: task: {
      assertion = task.user == "root" || task.createUser || config.users.users ? ${task.user};
      message = "User '${task.user}' for Tempus task '${name}' does not exist. Set createUser = true or ensure the user is defined elsewhere in your configuration.";
    }) cfg.tasks;
  };
}
