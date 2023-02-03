{ config, pkgs, ... }:
{

  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ libsForQt5.xdg-desktop-portal-kde ];
  };

}
