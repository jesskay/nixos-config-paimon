{ config, pkgs, lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      sddm-sugar-light = final.stdenv.mkDerivation rec {
        pname = "sddm-sugar-light-theme";
        version = "git-20190202";
        dontBuild = true;
        installPhase = ''
          mkdir -p $out/share/sddm/themes/sugar-light
          cp -aR $src/* $out/share/sddm/themes/sugar-light/
          sed -i \
              -e 's|^Background=.*$|Background=${pkgs.plasma-workspace-wallpapers}/share/wallpapers/Shell/contents/images/5120x2880.jpg|' \
              -e 's/^AccentColor=.*$/AccentColor="mediumpurple"/' \
              -e 's/^ScreenWidth=.*$/ScreenWidth=1920/' \
              -e 's/^ScreenHeight=.*$/ScreenHeight=1080/' \
              $out/share/sddm/themes/sugar-light/theme.conf
        '';
        src = final.fetchFromGitHub {
          owner = "MarianArlt";
          repo = "sddm-sugar-light";
          rev = "19bac00e7bd99e0388d289bdde41bf6644b88772";
          hash = "sha256-KddZtCTionZntQPD8ttXhHFLZl8b1NsawG9qbjuI1fc=";
        };
      };

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

      kde-rounded-corners = (prev.kde-rounded-corners.overrideAttrs (super: {
        version = "unstable-2022-12-20";
        src = final.fetchFromGitHub {
          owner = "matinlotfali";
          repo = "KDE-Rounded-Corners";
          rev = "cb6c31f5b58bf61a0c737669d2a0511748b7bfa6";
          hash = "sha256-ubocO0Vr3g5kIuGNV6vH+ySP42gFps9gPi5d3EpQVFY=";
        };
      }));
    })
  ];
}
