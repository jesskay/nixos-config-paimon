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
    active-flake.flake = inputs.self;
  };

  # enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # point global flake registry to a dummy file to remove default entries
  nix.settings.flake-registry = pkgs.writeText "dummy-registry.json"
  ''
    {
      "version": 2,
      "flakes": []
    }
  '';

  # automatic garbage collection
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
    dates = "weekly";
  };

  # enable nh helper
  programs.nh = {
    enable = true;
    flake = "${config.users.users.jess.home}/nixos-config-paimon";
  };

  # enable cachix cache for devenv
  nix.settings = {
    # limit builds to at most 2/3 of logical cores (12 on this machine)
    # - for typical builders, this is enforced as a load limit as well as
    #   passed as a job count, so it should never apply more than 8 cores
    #   worth of load, even when multiple jobs are running on all 12
    cores = 8;

    # trust root and anyone in wheel (as they could become root anyway if they wanted)
    trusted-users = [
      "root"
      "@wheel"
    ];

    trusted-public-keys = [
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
    ];

    substituters = [
      "https://devenv.cachix.org"
      "https://hyprland.cachix.org"
      "https://helix.cachix.org"
    ];
  };
}
