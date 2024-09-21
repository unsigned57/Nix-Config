{ ... }:

{
  programs = {
    git = {
      enable = true;
      lfs.enable = true;
    };

    lazygit = {
      enable = true;
    };
  };

  home-manager.users.ephemeral = {
    programs.git = {
      enable = true;
      userName = "unsigned57";
      userEmail = "unsigned57@gmail.com";
    };
  };
}
