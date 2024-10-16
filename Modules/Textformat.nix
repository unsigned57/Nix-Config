{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.markdownFormatter;

  formatterTaskOptions =
    { name, config, ... }:
    {
      options = {
        enable = mkEnableOption "Enable this formatter task";
        directory = mkOption {
          type = types.str;
          description = "Directory containing Markdown and text files to format";
        };
        interval = mkOption {
          type = types.str;
          default = cfg.defaultInterval;
          description = "How often to run this formatter task (systemd calendar event syntax)";
        };
        excludePatterns = mkOption {
          type = types.listOf types.str;
          default = [ ];
          example = [
            "*/node_modules/*"
            "*/vendor/*"
          ];
          description = "List of patterns to exclude from processing";
        };
        conversionRules = mkOption {
          type = types.attrsOf types.str;
          default = { };
          example = {
            "，" = ",";
            "。" = ".";
          };
          description = "Conversion rules as key-value pairs";
        };
      };
    };

  defaultConversionRules = {
    "　" = " ";
    "，" = ",";
    "：" = ":";
    "；" = ";";
    "？" = "?";
    "！" = "!";
    "（" = "(";
    "）" = ")";
    "［" = "[";
    "］" = "]";
    "【" = "[";
    "】" = "]";
    "(?<![a-zA-Z0-9]|\\.)\\." = "。";
  };

  generateFormatterScript =
    task:
    let
      rules = defaultConversionRules // task.conversionRules;
      ruleScript = concatStringsSep "\n" (
        mapAttrsToList (from: to: "s/${lib.escapeShellArg from}/${lib.escapeShellArg to}/g;") rules
      );
      parallelCommand = "perl -i -pe '${ruleScript}' {}; log \"Processed file: {}\"";
    in
    pkgs.writeShellApplication {
      name = "format-markdown-${task.name}";
      runtimeInputs = with pkgs; [
        coreutils
        findutils
        parallel
        perl
      ];
      text = ''
        set -euo pipefail
        export LANG=en_US.UTF-8

        log() {
          echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "${lib.escapeShellArg cfg.logFile}"
        }

        log "Starting Markdown/Text formatting for task: ${task.name}"

        find ${lib.escapeShellArg task.directory} \
          -type f \( -name "*.md" -o -name "*.markdown" -o -name "*.txt" \) \
          ${
            optionalString (task.excludePatterns != [ ])
              "-not ( ${
                concatMapStringsSep " -o " (pattern: "-path ${lib.escapeShellArg pattern}") task.excludePatterns
              } )"
          } \
          -print0 | 
        parallel -0 -j ${toString cfg.parallelJobs} \
          ${lib.escapeShellArg parallelCommand}

        log "Completed formatting for task: ${task.name}"
      '';
    };

in
{
  options.services.markdownFormatter = {
    enable = mkEnableOption "Markdown and text formatter service";

    tasks = mkOption {
      type = types.attrsOf (types.submodule formatterTaskOptions);
      default = { };
      description = "Formatter tasks configurations";
    };

    logFile = mkOption {
      type = types.str;
      default = "/var/log/markdown-formatter.log";
      description = "Path to the log file";
    };

    parallelJobs = mkOption {
      type = types.int;
      default = 4;
      description = "Number of parallel jobs for all tasks";
    };

    defaultInterval = mkOption {
      type = types.str;
      default = "daily";
      description = "Default interval for all tasks (systemd calendar event syntax)";
    };
  };

  config = mkIf cfg.enable {
    systemd.services = mapAttrs' (
      name: task:
      nameValuePair "markdownFormatter-${name}" {
        description = "Markdown/Text Formatter Service for ${name}";
        script = "${generateFormatterScript task}/bin/format-markdown-${name}";
        serviceConfig = {
          Type = "oneshot";
          IOSchedulingClass = "idle";
          CPUSchedulingPolicy = "idle";
          ProtectSystem = "strict";
          ProtectHome = "read-only";
          PrivateTmp = true;
          ReadWritePaths = [
            (dirOf cfg.logFile)
            task.directory
          ];
        };
      }
    ) (filterAttrs (name: task: task.enable) cfg.tasks);

    systemd.timers = mapAttrs' (
      name: task:
      nameValuePair "markdownFormatter-${name}" {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = task.interval;
          RandomizedDelaySec = "5m";
          Unit = "markdownFormatter-${name}.service";
        };
      }
    ) (filterAttrs (name: task: task.enable) cfg.tasks);

    system.activationScripts.markdownFormatterLogFile = ''
      mkdir -p "${lib.escapeShellArg (dirOf cfg.logFile)}"
      touch "${lib.escapeShellArg cfg.logFile}"
      chmod 644 "${lib.escapeShellArg cfg.logFile}"
    '';
  };
}
