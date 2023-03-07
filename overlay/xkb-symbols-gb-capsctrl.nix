{
  stdenv
, writeText
}:

stdenv.mkDerivation rec {
  pname = "xkb-symbols-gb-capsctrl";
  version = "1.0.0";

  src = ./gb-capsctrl.xkb;

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/X11/xkb/symbols
    cp $src $out/share/X11/xkb/symbols/custom
  '';
}
