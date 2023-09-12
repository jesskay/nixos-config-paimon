{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, agenix, ... }@inputs : let

    system = "x86_64-linux";

    pkgs-stable = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

  in {

    nixosConfigurations.paimon = nixpkgs-unstable.lib.nixosSystem {
      inherit system;
      modules =
        [ 
          ( { ... }: {   # Anonymous module to enable other modules to access flake inputs
            _module.args.inputs = inputs;
          })

          ( { ... }: {   # Anonymous module to inject a properly instantiated nixpkgs-stable into module args
            _module.args.pkgs-stable = pkgs-stable;
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
