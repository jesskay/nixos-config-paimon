{
  fetchFromGitHub,
  stdenv
}:

stdenv.mkDerivation {
  pname = "adi1090x-plymouth";
  version = "git-5d88174";

  src = fetchFromGitHub {
    owner = "adi1090x";
    repo = "plymouth-themes";
    rev = "5d8817458d764bff4ff9daae94cf1bbaabf16ede";
    hash = "sha256-e3lRgIBzDkKcWEp5yyRCzQJM6yyTjYC5XmNUZZroDuw=";
  };

  dontBuild = true;

  installPhase = let
    PLYMOUTH_THEME_DIR = "$out/share/plymouth/themes";
  in ''
    # create theme dir
    mkdir -p ${PLYMOUTH_THEME_DIR}

    # patch paths in .plymouth files
    sed -i \
        -e 's_/usr/share/plymouth/themes_'"${PLYMOUTH_THEME_DIR}"'_' \
        $PWD/pack_*/*/*.plymouth

    # copy packs
    cp -r $PWD/pack_*/* ${PLYMOUTH_THEME_DIR}/
  '';
}
