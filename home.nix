{ config, pkgs, inputs, lib, ... }:
{
  home.stateVersion = "24.05";

  home.username = "jess";
  home.homeDirectory = "/home/jess";

  # set up per-user nixpkgs config
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;

  # enable qt configuration
  qt = {
    enable = true;
    # platformTheme = "kde";
    style.name = "kvantum";
  };

  # configure kvantum theme (theme package installed globally, as it contains
  # themes used before login - SDDM, etc.)
  xdg.configFile."Kvantum/kvantum.kvconfig".text = lib.generators.toINI {} {
    General.theme = "MateriaDark";
  };

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
    beats
    brogue-ce
    heroic
    brother-ql-next
    (pkgs.writeShellApplication {
      name = "take-region-screenshot";
      text = builtins.readFile ./scripts/take-region-screenshot.sh;
      runtimeInputs = with pkgs; [
	feh                      # common
        maim xclip               # x11
	grim slurp wl-clipboard  # wayland
      ];
    })
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
  #  & set environment variables for printing to QL-570 with brother_ql
  programs.bash.bashrcExtra = ''
    export KITTY_SHELL_INTEGRATION="enabled"
    source "${pkgs.kitty}/lib/kitty/shell-integration/bash/kitty.bash"

    export BROTHER_QL_PRINTER=usb://0x04f9:0x2028
    export BROTHER_QL_MODEL=QL-570
    '';
}
