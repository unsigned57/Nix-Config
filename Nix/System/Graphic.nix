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
        rocm-opencl-icd
        rocm-opencl-runtime
        amdvlk
        vaapiVdpau
        ffmpeg_7-full
        libvdpau-va-gl
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };
}
