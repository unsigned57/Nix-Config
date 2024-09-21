{config,lib,pkgs,...}:

{
  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usbhid" "uas" "sd_mod" "sdhci_pci" ];
      kernelModules = [ ];
    };
  
    # kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = pkgs.linuxPackages_cachyos;
    kernelModules = [ "kvm-amd" "amdgpu" ];
    supportedFilesystems = [ "bcachefs" ];
    extraModulePackages = [ ]; 
  };

  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    enableRedistributableFirmware = lib.mkDefault true;
  };
}
