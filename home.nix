{ config, pkgs, inputs, ... }:
{
  # let home-manager manage itself
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    gimp
    shotcut
    ffmpeg
    prismlauncher
  ];

  programs.mpv = {
    enable = true;
    bindings = {
      "CTRL+-" = "add window-scale -0.125";
      "CTRL+0" = "set window-scale 1.0";
      "CTRL+=" = "add window-scale +0.125";
    };
  };
}
