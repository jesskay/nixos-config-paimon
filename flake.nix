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

    nixpkgs-firefoxpwa.url = "github:camillemndn/nixpkgs/firefoxpwa";

    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, agenix, nixos-cosmic, ... }@inputs : let

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

	  # cosmic testing
	  nixos-cosmic.nixosModules.default
	  {
	    nix.settings = {
	      substituters = [ "https://cosmic.cachix.org/" ];
	      trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
	    };
	    services.desktopManager.cosmic.enable = true;
	  }
        ];
    };

  };
}
