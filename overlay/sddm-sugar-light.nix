{
  plasma-workspace-wallpapers,
  fetchFromGitHub,
  stdenv
}:

stdenv.mkDerivation rec {
  pname = "sddm-sugar-light-theme";
  version = "git-20190202";

  src = fetchFromGitHub {
    owner = "MarianArlt";
    repo = "sddm-sugar-light";
    rev = "19bac00e7bd99e0388d289bdde41bf6644b88772";
    hash = "sha256-KddZtCTionZntQPD8ttXhHFLZl8b1NsawG9qbjuI1fc=";
  };

  dontBuild = true;
  installPhase = ''
    # patch out "password not blank" checks - security token login doesn't use password if token present
    sed -i \
        -e 's| && password.text !== ""||' \
        $PWD/Components/Input.qml

    # patch configuration
    sed -i \
        -e 's|^Background=.*$|Background=${plasma-workspace-wallpapers}/share/wallpapers/Shell/contents/images/5120x2880.jpg|' \
        -e 's/^AccentColor=.*$/AccentColor="mediumpurple"/' \
        -e 's/^ScreenWidth=.*$/ScreenWidth=1920/' \
        -e 's/^ScreenHeight=.*$/ScreenHeight=1080/' \
        $PWD/theme.conf

    # copy patched sddm into final output
    mkdir -p $out/share/sddm/themes/sugar-light
    cp -aR $PWD/* $out/share/sddm/themes/sugar-light/
  '';
}
