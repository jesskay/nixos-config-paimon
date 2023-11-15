{ config, pkgs, inputs, lib, ... }:
{
  home.stateVersion = "22.11";

  home.username = "jess";
  home.homeDirectory = "/home/jess";

  # rebuild KDE application cache on activation, to pick up new programs in the menu immediately
  home.activation.rebuildKsycoca = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD rm -r $HOME/.cache/ksycoca5_*
    $DRY_RUN_CMD ${pkgs.libsForQt5.kservice}/bin/kbuildsycoca5
  '';

  home.packages = with pkgs; [
    gimp
    blender
    krita
    shotcut
    ffmpeg
    hakuneko
    obs-studio
    obsidian
    pandoc
    prismlauncher
    fragments
    libreoffice-qt
    mosh
    warp
    xivlauncher
    mgba
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        mkhl.direnv
        rust-lang.rust-analyzer
      ];
    })
  ];

  # let home manager manage bash so that additions to its profile (e.g., direnv) can load
  programs.bash.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    delta.enable = true;
    userName = "Jessica Kay";
    userEmail = "jesskay@psquid.net";
    extraConfig.init.defaultbranch = "main";
  };

  programs.mpv = {
    enable = true;
    bindings = let
      rotate0 = "rotate=angle=0";
      rotate90 = "rotate=angle=PI/2:ow=ih:oh=iw";
      rotate180 = "rotate=angle=PI";
      rotate270 = "rotate=angle=-PI/2:ow=ih:oh=iw";
    in {
      # scaling
      "CTRL+-" = "add window-scale -0.125";
      "CTRL+0" = "set window-scale 1.0";
      "CTRL+=" = "add window-scale +0.125";
      # rotation, on the numpad corners, clockwise from 1 (which is no rotation)
      "KP1" = "no-osd set vf ${rotate0}";
      "KP7" = "no-osd set vf ${rotate90}";
      "KP9" = "no-osd set vf ${rotate180}";
      "KP3" = "no-osd set vf ${rotate270}";
      # and numpad 5 to cycle rotations (starting at 90 as at start there'll be no vf at all)
      "KP5" = "no-osd cycle-values vf ${rotate90} ${rotate180} ${rotate270} ${rotate0}";
    };
    config = {
      # (attempt to) unfuck dvd vobsubs
      stretch-dvd-subs = true;
      sub-gray = true;
      sub-gauss = 0.5;
    };
  };
}
