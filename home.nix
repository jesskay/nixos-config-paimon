{ config, pkgs, inputs, ... }:
{
  home.stateVersion = "22.11";

  home.username = "jess";
  home.homeDirectory = "/home/jess";

  # let home-manager manage itself
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    gimp
    shotcut
    ffmpeg
    prismlauncher
    fragments
    onlyoffice-bin
  ];

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
  };
}
