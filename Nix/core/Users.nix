{ config, ... }:

{
  users.users = {
    ephemeral = {
      isNormalUser = true;
      initialHashedPassword = "$7$CU..../....CPe41pA3LiPN.78DuV1Dq0$3P4wfNnfA6Gr5ubUbhoaZMcMymadypiFiysPHi79340";
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

    root = {
      initialHashedPassword = config.users.users.ephemeral.initialHashedPassword;
    };
  };
}
