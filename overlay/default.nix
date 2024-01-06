{ config, pkgs, lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      xkb-symbols-gb-capsctrl = final.callPackage ./xkb-symbols-gb-capsctrl.nix {};

      sddm-sugar-light = final.callPackage ./sddm-sugar-light.nix {};

      we10xos-dark = final.callPackage ./we10xos-dark.nix {};

      adi1090x-plymouth = final.callPackage ./adi1090x-plymouth.nix {};

      mloader = prev.mloader.overrideAttrs (super: {
        src = final.fetchFromGitHub {
          owner = "hurlenko";
          repo = "mloader";
          rev = "117689ccdf9c32fe1f4840cb5c11fc0ba759a400";
          hash = "sha256-mmAooUvaOML5Wq9DSmhPuzjdO4llLex5Qk776vwj7VU=";
        };

        postPatch = prev.mloader.postPatch + ''
          substituteInPlace mloader/loader.py \
            --replace '"app_ver": "1.8.3"' '"app_ver": "1.9.16"'
        '';

        propagatedBuildInputs = with final.python3Packages; [
          pillow
        ] ++ prev.mloader.propagatedBuildInputs;
      });

      kitty = let
        kittyIcon = final.fetchFromGitHub {
          owner = "DinkDonk";
          repo = "kitty-icon";
          rev = "269c0f0bd1c792cebc7821f299ce9250ed9bcd67";
          hash = "sha256-Vy+iLGnysrJMSLfkaYq15pb/wG4kIbfsXRrPgSc3OFs=";
        };
	convert = "${final.imagemagick}/bin/convert";
      in prev.kitty.overrideAttrs (super: {
        installPhase = (super.installPhase or "") + ''
          # replace the png icons and remove the svg icon
	  # - we use imagemagick to resize the icons to match the originals
          ${convert} ${kittyIcon}/kitty-dark.png \
	  	-resize 256x256 $out/lib/kitty/logo/kitty.png
          ${convert} ${kittyIcon}/kitty-dark.png \
	  	-resize 128x128 $out/lib/kitty/logo/kitty-128.png
          cp $out/lib/kitty/logo/kitty.png \
             $out/share/icons/hicolor/256x256/apps/kitty.png
          rm $out/share/icons/hicolor/scalable/apps/kitty.svg
          '';
      });

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
    })
  ];
}
