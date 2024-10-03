{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = false;
    fontDir.enable = true;

    packages = with pkgs; [
      material-design-icons
      font-awesome

      noto-fonts

      wqy_zenhei
      wqy_microhei
      lxgw-wenkai
      source-sans
      source-serif
      source-han-sans
      source-han-serif

      dejavu_fonts
      julia-mono

      (nerdfonts.override {
        fonts = [
          "NerdFontsSymbolsOnly"
          "FiraCode"
          "FiraMono"
          "JetBrainsMono"
          "Iosevka"
        ];
      })
    ];

    fontconfig = {
      enable = true;
      subpixel.rgba = "rgb";
      defaultFonts = {
        serif = [
          "Source Han Serif SC"
          "Source Han Serif TC"
          "Noto Color Emoji"
        ];
        sansSerif = [
          "Source Han Sans SC"
          "Source Han Sans TC"
          "Noto Color Emoji"
        ];
        monospace = [
          "JetBrainsMono Nerd Font"
          "Noto Color Emoji"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  services.kmscon = {
    enable = true;
    fonts = [
      {
        name = "Source Code Pro";
        package = pkgs.source-code-pro;
      }
    ];
    extraOptions = "--term xterm-256color";
    extraConfig = "font-size=24";
    hwRender = true;
  };
}
