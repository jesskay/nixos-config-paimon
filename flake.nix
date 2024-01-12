{
  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, agenix, ... }@inputs : let

    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

  in {

    nixosConfigurations.paimon = nixpkgs.lib.nixosSystem {
      inherit system;
      modules =
        [ 
          ( { ... }: {   # Anonymous module to enable other modules to access flake inputs
            _module.args.inputs = inputs;
          })

          # local modules
          ./configuration.nix
          ./configuration-agenix.nix
          ./configuration-borgbackup.nix
          ./configuration-flatpak.nix
          ./configuration-fonts.nix
          ./configuration-nix.nix
          ./configuration-yubikey.nix
          ./hardware-configuration.nix
          ./overlay
          # home manager module and anonymous module for its toplevel configuration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jess = import ./home.nix;
          }
          # agenix module
          agenix.nixosModules.default
        ];
    };

  };
}
