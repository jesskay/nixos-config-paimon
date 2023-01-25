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
    mkdir -p $out/share/sddm/themes/sugar-light
    cp -aR $src/* $out/share/sddm/themes/sugar-light/
    sed -i \
        -e 's|^Background=.*$|Background=${plasma-workspace-wallpapers}/share/wallpapers/Shell/contents/images/5120x2880.jpg|' \
        -e 's/^AccentColor=.*$/AccentColor="mediumpurple"/' \
        -e 's/^ScreenWidth=.*$/ScreenWidth=1920/' \
        -e 's/^ScreenHeight=.*$/ScreenHeight=1080/' \
        $out/share/sddm/themes/sugar-light/theme.conf
  '';
}
