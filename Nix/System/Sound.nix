{lib,config,...}:

{
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    wireplumber.enable = true;

    extraConfig = {
      client."99-resample"."stream.properties"."resample.quality" = 15;
      client-rt."99-resample"."stream.properties"."resample.quality" = 15;
      pipewire-pulse."99-resample"."stream.properties"."resample.quality" = 15;
      pipewire."99-allowed-rates"."context.properties"."default.clock.allowed-rates" = [
        44100
        48000
        88200
        96000
        176400
        192000
        358000
        384000
        716000
        768000
      ];
    };
  };
  
  hardware.pulseaudio.enable = lib.mkForce false;
  security.rtkit.enable = true;
}
