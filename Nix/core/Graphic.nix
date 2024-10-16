{ pkgs, ... }:

{
  chaotic = {
    hdr = {
      enable = true;
      specialisation.enable = false;
    };
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        # amdvlk
        ffmpeg_7-full
        libvdpau-va-gl
      ];
    };
  };
}
