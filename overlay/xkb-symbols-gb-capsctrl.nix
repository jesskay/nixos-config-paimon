{
  stdenv
, writeText
}:

stdenv.mkDerivation rec {
  pname = "xkb-symbols-gb-capsctrl";
  version = "1.0.0";

  src = writeText "gb-capsctrl" ''
    default partial alphanumeric_keys modifier_keys
    xkb_symbols "basic" {
        include "gb(basic)"

        name[Group1]="English (UK, Caps is LCtrl)";

        key <CAPS>      { [ Control_L, Control_L ] };
        modifier_map  Control { <CAPS>, <LCTL> };
    };
  '';

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/X11/xkb/symbols
    cp $src $out/share/X11/xkb/symbols/custom
  '';
}
