{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    zip
    lz4
    xz
    zstd
    parallel
    gnutar
    unzipNLS
    p7zip
    nixfmt-rfc-style
    zoxide
    lsd
    bottom
    fzf
    mcfly
    fd
    yazi
    fastfetch
    ptyxis
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
    ocrmypdf
    cmd-wrapped
    telegram-desktop
    amberol
    onlyoffice-desktopeditors
  ];

  programs = {
    adb.enable = true;
  };
}
