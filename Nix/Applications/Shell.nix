{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    shellInit = ''
      set fish_greeting #

      zoxide init fish | source

      set -U HISTSIZE 50000
      set -U HISTFILESIZE 10000
    '';
  };

  users.defaultUserShell = pkgs.fish;
}
