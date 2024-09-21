{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [ helix ];
    variables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };
  };

  home-manager.users.ephemeral = {
    programs.helix = {
      enable = true;
      defaultEditor = true;
      settings = {
        theme = "term16_light";
      };

      languages.language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt-classic}/bin/nixfmt-classic";
        }
      ];
    };
  };
}
