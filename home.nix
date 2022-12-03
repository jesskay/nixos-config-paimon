{ config, pkgs, inputs, ... }:
{
  # let home-manager manage itself
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    gimp
    shotcut
    ffmpeg
    mpv
    prismlauncher
  ];
}
