{ config, pkgs, ... }:

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

  # fileSystems."/run/media/ephemeral/linux" = {
  #   device = "/dev/disk/by-uuid/a1073e69-cf98-4198-99e5-c819a6c3317b";
  #   fsType = "f2fs";
  #   options = [
  #     "compress_algorithm=zstd:6"
  #     "compress_chksum"
  #     "atgc"
  #     "gc_merge"
  #     "lazytime"
  #     "nofail"
  #   ];
  # };

  environment.systemPackages = with pkgs; [
    f2fs-tools
    bcachefs-tools
    exfatprogs
  ];

  services = {
    udisks2.enable = true;
    devmon.enable = true;
    gvfs.enable = true;

    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_UUID}=="a1073e69-cf98-4198-99e5-c819a6c3317b", \
      RUN{program}+="${pkgs.systemd}/bin/systemd-mount --no-block --collect \
      --options=compress_algorithm=zstd:6,compress_chksum,atgc,gc_merge,lazytime \
      /dev/disk/by-uuid/a1073e69-cf98-4198-99e5-c819a6c3317b /run/media/%c/linux"
    '';
  };
}
