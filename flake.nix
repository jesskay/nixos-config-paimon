{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devenv.url = "github:cachix/devenv/v0.5";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs : let

    system = "x86_64-linux";

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
          ./configuration-flatpak.nix
          ./configuration-fonts.nix
          ./configuration-nix.nix
          ./configuration-yubikey.nix
          ./hardware-configuration.nix
          ./overlay

          # upstream modules from a newer nixos (current module must be disabled below if present in both versions)
          # : modules paths as strings: "${nixpkgs-unstable}/nixos/modules/path/to/module.nix"

          # inline module to disable nixos-stable modules where required
          # : list of paths relative to $REPO/nixos/modules/
          (_: { disabledModules = [ ]; })
        ];
    };

    homeConfigurations.jess = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      modules = [
        ( { ... }: {   # Anonymous module to enable other modules to access flake inputs
          _module.args.inputs = inputs;
        })

        # local modules
        ./home.nix
      ];
    };

  };
}
