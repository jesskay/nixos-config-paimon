{ config, pkgs, lib, ... }:
{
  fonts = {
    fonts = with pkgs; [
      # intentionally added fonts
      ubuntu_font_family
      fira
      fira-code
      ferrum
      roboto
      roboto-mono

      # fallbacks and "core" fonts
      # (enableDefaultFonts list as of 2022-12-18, but
      #  with twitter emoji instead of noto, and MS corefonts and migu added)
      dejavu_fonts
      freefont_ttf
      gyre-fonts  # TrueType substitutes for PostScript fonts
      liberation_ttf
      unifont
      twitter-color-emoji
      corefonts  # Microsoft "Core" TrueType fonts
      migu
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Ubuntu" ];
        sansSerif = [ "Roboto Sans" "Migu" ];
        monospace = [ "Roboto Mono" ];
        emoji = [ "Twitter Color Emoji" ];
      };
    };
  };
}
