{ config, pkgs, lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      xkb-symbols-gb-capsctrl = final.callPackage ./xkb-symbols-gb-capsctrl.nix {};

      sddm-sugar-light = final.callPackage ./sddm-sugar-light.nix {};

      we10xos-dark = final.callPackage ./we10xos-dark.nix {};

      adi1090x-plymouth = final.callPackage ./adi1090x-plymouth.nix {};

      discord-fixup = ((prev.discord.overrideAttrs (super: {
        # modify shortcut at the end of the install phase to force 80ms pulse latency
        installPhase = (super.installPhase or "") + ''
          # copy the content out of the symlinked applications dir so we can actually work with it
          # (otherwise it's in a different derivation and perms won't let us touch it)
          mkdir -p $out/share/applications-copy
          cp -a $out/share/applications/* $out/share/applications-copy/
          rm $out/share/applications
          mv $out/share/applications-copy $out/share/applications

          # patch the desktop item in place
          sed 's/^Exec=/Exec=env PULSE_LATENCY_MSEC=200 /' -i $out/share/applications/discord.desktop
          '';
      })).override {  # override to use the same nss as firefox
        # will need updating if firefox ever uses a non-latest nss
        # obsoleted if/when https://github.com/NixOS/nixpkgs/pull/186603 lands
        nss = final.nss_latest;
      });

      # xivlauncher 1.0.5 from PR 258794
      # with assert to override *only* if upstream nixpkgs hasn't updated yet
      xivlauncher = assert prev.xivlauncher.version == "1.0.4"; final.callPackage ./xivlauncher {};
    })
  ];
}
