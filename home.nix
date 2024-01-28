{ config, pkgs, inputs, lib, ... }:
{
  home.stateVersion = "24.05";

  home.username = "jess";
  home.homeDirectory = "/home/jess";

  # rebuild KDE application cache on activation, to pick up new programs in the menu immediately
  home.activation.rebuildKsycoca = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD rm -r $HOME/.cache/ksycoca5_*
    $DRY_RUN_CMD ${pkgs.libsForQt5.kservice}/bin/kbuildsycoca5
  '';

  home.packages = with pkgs; [
    kitty
    gimp
    inkscape
    blender
    krita
    shotcut
    ffmpeg
    mloader
    calibre
    obs-studio
    pandoc
    prismlauncher
    fragments
    obsidian
    mosh
    warp
    xivlauncher
    mgba
    (pkgs.writeScriptBin "take-region-screenshot" ''
      #!/usr/bin/env bash

      ${pkgs.maim}/bin/maim -u \
      | (${pkgs.feh}/bin/feh -F - & ${pkgs.maim}/bin/maim -s && kill %?feh) \
      | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png
    '')
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

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = ''
      set title
      set tw=80
      set colorcolumn=+1
    '';
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

  # Install kitty config to XDG config path
  xdg.configFile."kitty/kitty.conf".source = ./dotfiles/kitty.conf;

  # Enable kitty bash integration
  programs.bash.bashrcExtra = ''
    export KITTY_SHELL_INTEGRATION="enabled"
    source "${pkgs.kitty}/lib/kitty/shell-integration/bash/kitty.bash"
    '';
}
