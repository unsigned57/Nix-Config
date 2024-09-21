{config,...}:

{
  users.users.ephemeral = {
    isNormalUser = true;
    extraGroups = [ 
      "wheel"
      "users"
      "networkmanager"
      "video"
      "adbusers"
      "kvm"
      "libvirtd"
      "plugdev"
      "tss"
    ];
  };
}
