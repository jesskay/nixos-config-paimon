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

  # Daemon service tuning - half of normal CPU weight, and a memory soft limit
  # of half physical RAM, and hard limit of 3/4 physical RAM.
  #
  # This should hopefully be high enough to avoid significant slowdown on
  # interactive use of the daemon (nix shell, etc.) while preventing
  # noninteractive uses (nixos-rebuild primarily) from interfering with
  # other processes
  systemd.services.nix-daemon.serviceConfig = {
    CPUWeight = 50;
    MemoryHigh = "8G";
    MemoryMax = "12G";
  };

  # automatic garbage collection
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
    dates = "weekly";
  };

  # enable cachix cache for devenv
  nix.settings = {
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
