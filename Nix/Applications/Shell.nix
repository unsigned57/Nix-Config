{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting #
      zoxide init fish | source
    '';
  };

  users.defaultUserShell = pkgs.fish;
}
