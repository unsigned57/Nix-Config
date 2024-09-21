{
  pkgs,
  lib,
  config,
  ...
}:

{
  environment = {
    systemPackages = with pkgs; [
      sbctl
      tpm2-tools
    ];

    memoryAllocator = {
      provider = "scudo";
    };

    etc = {
      "modprobe.d/nm-disable-intelme-kmodules.conf" = {
        text = ''
          install mei /usr/bin/disabled-intelme-by-security-misc
          install mei-gsc /usr/bin/disabled-intelme-by-security-misc
          install mei_gsc_proxy /usr/bin/disabled-intelme-by-security-misc
          install mei_hdcp /usr/bin/disabled-intelme-by-security-misc
          install mei-me /usr/bin/disabled-intelme-by-security-misc
          install mei_phy /usr/bin/disabled-intelme-by-security-misc
          install mei_pxp /usr/bin/disabled-intelme-by-security-misc
          install mei-txe /usr/bin/disabled-intelme-by-security-misc
          install mei-vsc /usr/bin/disabled-intelme-by-security-misc
          install mei-vsc-hw /usr/bin/disabled-intelme-by-security-misc
          install mei_wdt /usr/bin/disabled-intelme-by-security-misc
          install microread_mei /usr/bin/disabled-intelme-by-security-misc
        '';
      };

      machine-id.text = ''
        b08dfa6083e7567a1921a715000001fb
      '';
    };
  };

  boot = {
    loader.systemd-boot.enable = lib.mkForce false;

    lanzaboote = {
      enable = true;
      pkiBundle = "/nix/persistent/etc/secureboot";
    };

    kernelModules = [
      "jitterentropy_rng"
      # "mitigations=auto"
    ];

    kernelParams = [
      "randomize_kstack_offset=on"
      "iommu.passthrough=0"
      "amd_iommu=force_isolation"
      "iommu=force"
      "iommu.strict=1"
    ];

    kernel.sysctl = {
      "kernel.kptr_restrict" = "2";
      "kernel.dmesg_restrict" = "1";
      "kernel.randomize_va_space" = "2";
      "net.ipv4.conf.all.accept_redirects" = "0";
      "net.ipv4.conf.default.accept_redirects" = "0";
      "net.ipv4.conf.all.secure_redirects" = "0";
      "net.ipv4.conf.default.secure_redirects" = "0";
      "net.ipv6.conf.all.accept_redirects" = "0";
      "net.ipv6.conf.default.accept_redirects" = "0";
    };
  };

  services = {
    jitterentropy-rngd.enable = true;

    chrony = {
      enable = true;
      enableNTS = true;
      servers = [
        "time.cloudflare.com"
        "nts.sth1.ntp.se"
        "nts.sth2.ntp.se"
      ];
    };
  };

  networking.networkmanager = {
    ethernet.macAddress = "random";
    wifi = {
      macAddress = "random";
      scanRandMacAddress = true;
    };
    connectionConfig."ipv6.ip6-privacy" = 2;
  };

  security = {
    tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
      # abrmd.enable = true;
    };

    apparmor = {
      enable = true;
      # killUnconfinedConfinables = true;
    };

    pam = {
      loginLimits = [
        {
          domain = "*";
          type = "soft";
          item = "nofile";
          value = "524288";
        }
        {
          domain = "*";
          type = "hard";
          item = "nofile";
          value = "1048576";
        }
      ];
    };
  };
}
