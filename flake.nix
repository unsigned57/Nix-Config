{
  description = "my flake config";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager ={
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";
    
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    
    daeuniverse.url = "github:daeuniverse/flake.nix/unstable";

    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    preservation.url = "github:WilliButz/preservation";

    # agenix.url = "github:ryantm/agenix";
  };

  outputs = inputs@{
    self,
    nixpkgs,
    nixos-cosmic,
    home-manager,
    chaotic,
    nix-flatpak,
    lanzaboote,
    impermanence,
    preservation,
    # agenix,
    ...
  }: {
    nixosConfigurations.ephemeral = nixpkgs.lib.nixosSystem rec{
      system = "x86_64-linux";
      modules = [
        ./Nix/System
        ./Nix/Applications

        chaotic.nixosModules.default
      
        home-manager.nixosModules.home-manager
        {
          home-manager = 
          {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
            users = {
              ephemeral.imports = [
                nix-flatpak.homeManagerModules.nix-flatpak
                ./Nix/Applications/home.nix
              ];
            };
          };
        }
        
        inputs.daeuniverse.nixosModules.dae
        inputs.daeuniverse.nixosModules.daed
         
        nixos-cosmic.nixosModules.default

        lanzaboote.nixosModules.lanzaboote
        
        impermanence.nixosModules.impermanence

        preservation.nixosModules.preservation

        # agenix.nixosModules.default
      ];
    };
  };
}
