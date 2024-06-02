{ config, pkgs, lib, ... }:
{
  fonts = {
    packages = with pkgs; [
      # intentionally added fonts
      ubuntu_font_family
      fira
      fira-code
      ferrum
      roboto
      roboto-mono
      roboto-slab
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      cabin
      overpass
      iosevka
      iosevka-comfy.comfy-motion
      iosevka-comfy.comfy-wide-motion

      # fallbacks and "core" fonts
      # (enableDefaultFonts list as of 2022-12-18, but
      #  with twitter emoji instead of noto, and MS corefonts added)
      dejavu_fonts
      freefont_ttf
      gyre-fonts  # TrueType substitutes for PostScript fonts
      liberation_ttf
      unifont
      twitter-color-emoji
      corefonts  # Microsoft "Core" TrueType fonts
    ];

    fontconfig = {
      defaultFonts = {
        serif = [
	  "Noto Serif"
	  "Noto Serif Japanese"
	  "Noto Serif Korean"
	  "Noto Serif Traditional Chinese"
	];
        sansSerif = [
	  "Noto Sans"
	  "Noto Sans Japanese"
	  "Noto Sans Korean"
	  "Noto Sans Traditional Chinese"
	];
        monospace = [ "Roboto Mono" ];
        emoji = [ "Twitter Color Emoji" ];
      };
    };
  };
}
