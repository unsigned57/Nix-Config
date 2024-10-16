{ pkgs, ... }:

{
  virtualisation = {
    containers.enable = true;

    lxd.enable = true;
    waydroid.enable = true;

    libvirtd = {
      enable = true;
      qemu.runAsRoot = true;
    };

    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  boot = {
    kernelModules = [ "vfio-pci" ];
    extraModprobeConfig = ''
      options kvm ignore_msrs=1
    '';
  };

  networking = {
    firewall = {
      allowedTCPPorts = [
        53
        67
      ];
      trustedInterfaces = [ "waydroid0" ];
    };

    nat = {
      enable = true;
      externalInterface = "dae0";
      internalInterfaces = [ "waydroid0" ];
    };
  };

  environment.systemPackages = with pkgs; [
    virt-manager
    qemu_kvm
    qemu

    distrobox

    quickemu
  ];
}
