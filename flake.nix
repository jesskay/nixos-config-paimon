{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    devenv.url = "github:cachix/devenv/latest";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs : let

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
          ./configuration-flatpak.nix
          ./configuration-fonts.nix
          ./configuration-nix.nix
          ./configuration-yubikey.nix
          ./hardware-configuration.nix
          ./overlay
        ];
    };

    homeConfigurations.jess = home-manager.lib.homeManagerConfiguration {
      pkgs = pkgs-unstable;

      modules = [
        ( { ... }: {   # Anonymous module to enable other modules to access flake inputs
          _module.args.inputs = inputs;
        })

        ( { ... }: {   # Anonymous module to inject a properly instantiated nixpkgs-stable into module args
          _module.args.pkgs-stable = pkgs-stable;
        })

        # local modules
        ./home.nix
      ];
    };

  };
}
