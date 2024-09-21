{ pkgs, config, ... }:

{
  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      videoDrivers = [ "amdgpu" ];
    };

    # displayManager = {
    #   enable = true;
    #   cosmic-greeter.enable = true;
    # };

    #   desktopManager = {
    #     cosmic.enable = true;
    #   };

    #   greetd = {
    #     enable = true;
    #     settings = rec {
    #       initial_session = {
    #         command = "start-cosmic";
    #         user = "ephemeral";
    #       };
    #       default_session = initial_session;
    #     };
    #   };
  };

  environment = {
    gnome = {
      excludePackages = with pkgs; [
        cheese
        epiphany
        evince
        totem
        tali
        iagno
        hitori
        atomix
        geary
        gnome-maps
        gnome-music
        gnome-software
        gnome-connections
        gnome-contacts
        gnome-tour
      ];
    };

    systemPackages =
      (with pkgs; [
        gnome-tweaks
        bibata-cursors
      ])
      ++ (with pkgs.gnomeExtensions; [
        blur-my-shell
        paperwm
        runcat
      ]);
  };

  nixpkgs.overlays = [
    (final: prev: {
      gnome = prev.gnome.overrideScope (
        gnomeFinal: gnomePrev: {
          mutter = gnomePrev.mutter.overrideAttrs (old: {
            src = pkgs.fetchFromGitLab {
              domain = "gitlab.gnome.org";
              owner = "vanvugt";
              repo = "mutter";
              rev = "triple-buffering-v4-46";
              hash = "sha256-fkPjB/5DPBX06t7yj0Rb3UEuu5b9mu3aS+jhH18+lpI=";
            };
          });
        }
      );
    })
  ];
}
