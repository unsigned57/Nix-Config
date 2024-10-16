{ pkgs, ... }:

{
  services.flatpak.enable = true;

  home-manager.users.ephemeral = {
    services.flatpak = {
      enable = true;
      remotes = [
        {
          name = "flathub-beta";
          location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
        }
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
      ];

      uninstallUnmanaged = true;
      update.auto = {
        enable = true;
        onCalendar = "weekly";
      };

      packages = [
        "org.gnome.Solanum"
        "io.github.giantpinkrobots.flatsweep"
        "io.github.zen_browser.zen"
        "com.valvesoftware.Steam"
        "md.obsidian.Obsidian"
        "com.github.tchx84.Flatseal"
      ];
    };
  };
}
