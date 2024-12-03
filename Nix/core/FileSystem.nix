{ config, pkgs, ... }:

{
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "size=25%"
        "defaults"
        "mode=755"
      ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/5e215797-f5a2-47ff-b450-a78bd7e3d143";
      fsType = "bcachefs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/8F7C-E329";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/62b83721-ce98-48db-b1d1-88e179b9eac5"; }
  ];

  environment.systemPackages = with pkgs; [
    f2fs-tools
    bcachefs-tools
    exfatprogs
    fuse3
  ];

  services = {
    udisks2.enable = true;
    gvfs.enable = true;
    udev.extraRules = ''
      ACTION=="add|change", SUBSYSTEM=="block", ENV{ID_FS_TYPE}=="f2fs", \
      ENV{UDISKS_MOUNT_OPTIONS_DEFAULTS}="compress_algorithm=zstd:6,compress_chksum,atgc,gc_merge,lazytime"

      ACTION=="add|change", SUBSYSTEM=="block", ENV{ID_FS_TYPE}=="exfat", \
      ENV{UDISKS_MOUNT_OPTIONS_DEFAULTS}="uid=$UID,gid=100,fmask=0133,dmask=0022,iocharset=utf8,errors=remount-ro"
    '';
  };
}
