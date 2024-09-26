{ pkgs, ... }:

{
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "size=25%"
      "defaults"
      "mode=755"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/5e215797-f5a2-47ff-b450-a78bd7e3d143";
    fsType = "bcachefs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/8F7C-E329";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/62b83721-ce98-48db-b1d1-88e179b9eac5"; }
  ];

  environment.systemPackages = with pkgs; [
    f2fs-tools
    bcachefs-tools
    exfatprogs
  ];
}
