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

    "/run/media/ephemeral/linux" = {
      device = "/dev/disk/by-uuid/a1073e69-cf98-4198-99e5-c819a6c3317b";
      fsType = "f2fs";
      options = [
        "nofail"
        "compress_algorithm=zstd:6"
        "compress_chksum"
        "atgc"
        "gc_merge"
        "lazytime"
      ];
    };

    "/run/media/ephemeral/win" = {
      device = "/dev/disk/by-uuid/77F3-F32B";
      fsType = "exfat";
      options = [
        "nofail"
        "uid=1000"
        "gid=100"
        "fmask=0133"
        "dmask=0022"
        "iocharset=utf8"
        "errors=remount-ro"
        "discard"
      ];
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
    devmon.enable = true;
    gvfs.enable = true;

    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_UUID}=="a1073e69-cf98-4198-99e5-c819a6c3317b", \
      RUN{program}+="${pkgs.systemd}/bin/systemd-mount --no-block --collect \
      --options=compress_algorithm=zstd:6,compress_chksum,atgc,gc_merge,lazytime \
      /dev/disk/by-uuid/a1073e69-cf98-4198-99e5-c819a6c3317b /run/media/%E/linux"

      ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_UUID}=="77F3-F32B", \
      RUN{program}+="${pkgs.systemd}/bin/systemd-mount --no-block --collect \
      --options=uid=%E,gid=%E,fmask=0133,dmask=0022,iocharset=utf8,errors=remount-ro,discard \
      /dev/disk/by-uuid/77F3-F32B /run/media/%E/win"
    '';
  };
}
