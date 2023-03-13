{ config, pkgs, ... }:
{
  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  security.pam.yubico = {
    enable = true;
    mode = "challenge-response";
  };
  
  environment.systemPackages = with pkgs; [
    yubioath-flutter
  ];
}
