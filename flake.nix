{
  description = "my flake config";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };

    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    };

    daeuniverse = {
      url = "github:daeuniverse/flake.nix";
    };

    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    preservation = {
      url = "github:WilliButz/preservation";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixos-cosmic,
      home-manager,
      chaotic,
      nix-flatpak,
      lanzaboote,
      impermanence,
      preservation,
      ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.ephemeral = nixpkgs.lib.nixosSystem rec {
        modules = [
          ./Nix/System
          ./Nix/Applications
          ./Modules

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit inputs;
              };
              users = {
                ephemeral.imports = [
                  nix-flatpak.homeManagerModules.nix-flatpak
                  ./Nix/Applications/home.nix
                ];
              };
            };
          }

          chaotic.nixosModules.default

          inputs.daeuniverse.nixosModules.dae
          inputs.daeuniverse.nixosModules.daed

          nixos-cosmic.nixosModules.default

          lanzaboote.nixosModules.lanzaboote

          impermanence.nixosModules.impermanence

          preservation.nixosModules.preservation
        ];
      };
    };
}
