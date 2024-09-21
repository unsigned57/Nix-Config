{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    zip
    lz4
    xz
    zstd
    unzipNLS
    p7zip
    bcachefs-tools
    nixfmt-rfc-style
    zoxide
    lsd
    bottom
    fzf
    mcfly
    fd
    yazi
    fastfetch
  ];

  users.users.ephemeral.packages = with pkgs; [
    scrcpy
    foliate
    newsflash
    loupe
    clapper
    mission-center
    wthrr
    kalker
    genact
    upscayl
    localsend
    signal-desktop
    anki-bin
    telegram-desktop
  ];

  programs = {
    adb.enable = true;
  };
}
