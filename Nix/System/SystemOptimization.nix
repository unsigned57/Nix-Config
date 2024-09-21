{ ... }:

{
  boot = {
    kernel.sysctl = {
      "net.core.default_qdisc" = "cake";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.optmem_max" = 65536;
      "net.core.rmem_default" = 1048576;
      "net.core.rmem_max" = 16777216;
      "net.core.somaxconn" = 8192;
      "net.core.wmem_default" = 1048576;
      "net.core.wmem_max" = 16777216;
      "net.core.netdev_max_backlog" = 16384;
      "net.ipv4.conf.all.log_martians" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.log_martians" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.ip_local_port_range" = "16384 65535";
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_keepalive_time" = 60;
      "net.ipv4.tcp_keepalive_intvl" = 10;
      "net.ipv4.tcp_keepalive_probes" = 6;
      "net.ipv4.tcp_max_syn_backlog" = 8192;
      "net.ipv4.tcp_max_tw_buckets" = 2000000;
      "net.ipv4.tcp_mtu_probing" = 1;
      "net.ipv4.tcp_rfc1337" = 1;
      "net.ipv4.tcp_rmem" = "4096 1048576 2097152";
      "net.ipv4.tcp_slow_start_after_idle" = 0;
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_tw_reuse" = 1;
      "net.ipv4.tcp_wmem" = "4096 65536 16777216";
      "net.ipv4.udp_rmem_min" = 8192;
      "net.ipv4.udp_wmem_min" = 8192;
      "net.netfilter.nf_conntrack_generic_timeout" = 60;
      "net.netfilter.nf_conntrack_max" = 1048576;
      "net.netfilter.nf_conntrack_tcp_timeout_established" = 600;
      "net.netfilter.nf_conntrack_tcp_timeout_time_wait" = 1;
      #      "vm.dirty_ratio" = 10;
      #      "vm.dirty_background_ratio" = 5;
      "vm.max_map_count" = 2147483642;
      #      "vm.swappiness" = 10;
      #      "vm.vfs_cache_pressure" = 50;
      "kernel.sched_autogroup_enabled" = 1;
    };

    kernelParams = [
      "tsc=reliable"
      "clocksource=tsc"
      "transparent_hugepage=madvise"
      # "numa_balancing=enable"
      # "amd_pstate=active"
      "watchdog_thresh=60"
      # "quiet"
      # "splash"
    ];

    initrd.compressor = "zstd";
  };

  services = {
    fstrim.enable = true;
    irqbalance.enable = true;
    preload.enable = true;
    auto-cpufreq.enable = true;
    power-profiles-daemon.enable = false;

    udev.extraRules = ''
      ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"
    '';

    journald.extraConfig = ''
      SystemMaxUse=100M
      MaxRetentionSec=7day
    '';
  };

  hardware = {
    ksm.enable = true;
  };

  chaotic.scx = {
    enable = true;
    scheduler = "scx_rusty";
  };

  systemd = {
    oomd = {
      enable = true;
      enableSystemSlice = true;
      enableUserSlices = true;
    };

    extraConfig = ''
      DefaultTimeoutStartSec=20s
      DefaultTimeoutStopSec=20s
    '';
    user.extraConfig = ''
      DefaultTimeoutStartSec=20s
      DefaultTimeoutStopSec=20s
    '';
  };
}
