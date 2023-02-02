{
  plasma-workspace-wallpapers,
  fetchFromGitHub,
  stdenv
}:

stdenv.mkDerivation rec {
  pname = "we10xos-dark";
  version = "git-20221219";

  src = fetchFromGitHub {
    owner = "yeyushengfan258";
    repo = "We10XOS-kde";
    rev = "509b032b6ea997a774e9afaf6c47ed1020622607";
    hash = "sha256-NpAdNX/bMpGLRam8qoHF7kuCMmt4JTiwwNCjRmkARWg=";
  };

  dontBuild = true;
  installPhase = let
    AURORAE_DIR = "$out/share/aurorae/themes";
    SCHEMES_DIR = "$out/share/color-schemes";
    PLASMA_DIR = "$out/share/plasma/desktoptheme";
    LAYOUT_DIR = "$out/share/plasma/layout-templates";
    LOOKFEEL_DIR = "$out/share/plasma/look-and-feel";
    KVANTUM_DIR = "$out/share/Kvantum";
    SDDM_DIR = "$out/share/sddm/themes";
    WALLPAPER_DIR = "$out/share/wallpapers";
  in ''
    # create theme directories
    mkdir -p ${AURORAE_DIR}
    mkdir -p ${SCHEMES_DIR}
    mkdir -p ${PLASMA_DIR}
    mkdir -p ${LOOKFEEL_DIR}
    mkdir -p ${KVANTUM_DIR}
    mkdir -p ${SDDM_DIR}
    mkdir -p ${WALLPAPER_DIR}

    # patch configuration
    sed -i \
        -e 's|^background=.*$|background=${plasma-workspace-wallpapers}/share/wallpapers/Shell/contents/images/5120x2880.jpg|' \
        $PWD/sddm/We10XOS/theme.conf

    # patch text input background
    sed -i \
        -e '/color: "#633700"/a opacity: 0.35' \
        -e 's/color: "#633700"/color: "#000000"/' \
        $PWD/sddm/We10XOS/Login.qml

    # patch background scaling
    sed -i \
        -e 's/fillMode: Image.PreserveAspectCrop/fillMode: Image.PreserveAspectFill/' \
        $PWD/sddm/We10XOS/Background.qml

    # copy files into theme directories
    cp -r $PWD/aurorae/*                ${AURORAE_DIR}
    cp -r $PWD/color-schemes/*.colors   ${SCHEMES_DIR}
    cp -r $PWD/Kvantum/*                ${KVANTUM_DIR}
    cp -r $PWD/plasma/desktoptheme/*    ${PLASMA_DIR}
    cp -r $PWD/plasma/look-and-feel/*   ${LOOKFEEL_DIR}
    cp -r $PWD/sddm/We10XOS             ${SDDM_DIR}/
    cp -r $PWD/wallpaper/*              ${WALLPAPER_DIR}
  '';
}

