{lib,...}:

{
  networking = {
    hostName = "ephemeral";
    useDHCP = lib.mkDefault true;
    firewall.allowedTCPPorts = [22 53317];
    
    networkmanager = {
      enable = true;         
    };

    timeServers = [
      "ntp.aliyun.com"
      "ntp.tencent.com"
    ];
  };
}
