(self: super: {
  xkb-symbols-gb-capsctrl = self.callPackage ./xkb-symbols-gb-capsctrl.nix {};

  sddm-sugar-light = self.callPackage ./sddm-sugar-light.nix {};

  we10xos-dark = self.callPackage ./we10xos-dark.nix {};

  adi1090x-plymouth = self.callPackage ./adi1090x-plymouth.nix {};

  mloader = super.mloader.overrideAttrs {
    src = self.fetchFromGitHub {
      owner = "hurlenko";
      repo = "mloader";
      rev = "117689ccdf9c32fe1f4840cb5c11fc0ba759a400";
      hash = "sha256-mmAooUvaOML5Wq9DSmhPuzjdO4llLex5Qk776vwj7VU=";
    };

    postPatch = super.mloader.postPatch + ''
      substituteInPlace mloader/loader.py \
        --replace-warn '"app_ver": "1.8.3"' '"app_ver": "1.9.22"'
    '';

    propagatedBuildInputs = with self.python3Packages; [
      pillow
    ] ++ super.mloader.propagatedBuildInputs;
  };

  kitty = let
    kittyIcon256 = ./kitty.png;
    kittyIcon128 = ./kitty-128.png;
  in super.kitty.overrideAttrs (previousAttrs: {
    installPhase = (previousAttrs.installPhase or "") + ''
      # replace the png icons and remove the svg icon
      rm $out/share/icons/hicolor/scalable/apps/kitty.svg
      cp ${kittyIcon256} $out/share/icons/hicolor/256x256/apps/kitty.png
      cp ${kittyIcon256} $out/lib/kitty/logo/kitty.png
      cp ${kittyIcon128} $out/lib/kitty/logo/kitty-128.png
      '';
  });

  vivaldi = super.vivaldi.override {
    enableWidevine = true;
    proprietaryCodecs = true;
  };

  discord-fixup = ((super.discord.overrideAttrs (previousAttrs: {
    # modify shortcut at the end of the install phase to force 80ms pulse latency
    installPhase = (previousAttrs.installPhase or "") + ''
      # copy the content out of the symlinked applications dir so we can actually work with it
      # (otherwise it's in a different derivation and perms won't let us touch it)
      mkdir -p $out/share/applications-copy
      cp -a $out/share/applications/* $out/share/applications-copy/
      rm $out/share/applications
      mv $out/share/applications-copy $out/share/applications

      # fail if the patching commands fail
      set -e

      # patch in arguments in-place
      sed 's/Exec=Discord/Exec=Discord --enable-features=UseOzonePlatform --ozone-platform=wayland/' \
      	-i $out/share/applications/discord.desktop

      # patch in environment variables in-place
      sed 's/^Exec=/Exec=env PULSE_LATENCY_MSEC=200 /' -i $out/share/applications/discord.desktop
      '';
  })).override {  # override to use the same nss as firefox
    # will need updating if firefox ever uses a non-latest nss
    # obsoleted if/when https://github.com/NixOS/nixpkgs/pull/186603 lands
    nss = self.nss_latest;
  });
})
