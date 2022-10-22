{ config, pkgs, lib, inputs, ... }:
{
  # Let 'nixos-version --json' know about the Git revision
  # of this flake.
  system.configurationRevision = lib.mkIf (inputs.self ? rev) inputs.self.rev;

  # configure NIX_PATH entries
  nix.nixPath = [
    "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  # set up various useful registry entries
  nix.registry = {
    # `nixpkgs` is set to the same nixpkgs flake used to build this configuration
    nixpkgs.flake = inputs.nixpkgs;

    # `templates` is set to the same as the global registry, so `nix flake init` can work
    templates.to = { type = "github"; owner = "NixOS"; repo = "templates"; };

    # `active-config` is set to the flake the current system was built from
    active-config.flake = inputs.self;
  };

  # enable flakes and point global repository to a dummy file
  nix.extraOptions = 
  let
    dummyRegistry = pkgs.writeText "dummy-registry.json"
    ''
      {
        "version": 2,
        "flakes": []
      }
    '';
  in ''
    experimental-features = nix-command flakes
    flake-registry = ${dummyRegistry}
  '';

  # automatic garbage collection
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
    dates = "weekly";
  };
}
