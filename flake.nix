{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

  outputs = { self, nixpkgs, ... }@inputs : {

    nixosConfigurations.paimon = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [ 
          ( { ... }: {   # Anonymous module to enable other modules to access flake inputs
            _module.args.inputs = inputs;
          })

          # local modules
          ./configuration.nix
          ./configuration-nix.nix
          ./hardware-configuration.nix

          # upstream modules from a newer nixos (current module must be disabled below if present in both versions)
          # : modules paths as strings: "${nixpkgs-unstable}/nixos/modules/path/to/module.nix"

          # inline module to disable nixos-stable modules where required
          # : list of paths relative to $REPO/nixos/modules/
          (_: { disabledModules = [ ]; })
        ];
    };

  };
}
