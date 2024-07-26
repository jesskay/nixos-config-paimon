(self: super: {
  xkb-symbols-gb-capsctrl = self.callPackage ./xkb-symbols-gb-capsctrl.nix {};

  sddm-sugar-light = self.callPackage ./sddm-sugar-light.nix {};

  we10xos-dark = self.callPackage ./we10xos-dark.nix {};

  adi1090x-plymouth = self.callPackage ./adi1090x-plymouth.nix {};

  brother-ql = self.callPackage ./brother-ql-next.nix {};

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
})
