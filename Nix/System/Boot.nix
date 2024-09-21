{ lib, ... }:

{
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = lib.mkDefault 50;
      consoleMode = lib.mkDefault "max";
    };

    efi.canTouchEfiVariables = true;
  };
}
