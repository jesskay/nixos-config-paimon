# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Windows filesystems (read only)
  fileSystems."/media/win-c" = {
    device = "/dev/disk/by-uuid/B062794C627917F4";
    fsType = "ntfs";
    options = [ "defaults" "ro" ];
  };
  
  fileSystems."/media/win-e" = {
    device = "/dev/disk/by-label/Data";
    fsType = "ntfs";
    options = [ "defaults" "ro" ];
  };

  networking.hostName = "paimon"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable wake-on-lan
  networking.interfaces."enp34s0".wakeOnLan.enable = true;

  # Enable tailscale
  services.tailscale.enable = true;
  networking.firewall = {
    trustedInterfaces = [ "tailscale0" "enp34s0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # Enable libvirtd
  virtualisation.libvirtd.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.utf8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable KDE Plasma.
  services.xserver.displayManager.sddm = { 
    enable = true;
    theme = "sugar-light";
    settings.General.InputMethod = "";  # disable virtual keyboard
  };
  services.xserver.desktopManager.plasma5.enable = true;

  # Enable dconf to ensure GTK themes are applied under Wayland
  programs.dconf.enable = true;

  # Enable KDE Connect
  programs.kdeconnect.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "gb";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable ratbagd to configure gaming mice
  services.ratbagd.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jess = {
    isNormalUser = true;
    description = "Jessica Kay";
    uid = 1000;  # set explicitly for consistency
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = with pkgs; [
      firefox
      discord-fixup  # from overlay
      keepassxc
    ];
  };

  # Enable onedrive mount for jess
  systemd.services."rclone-onedrive-jess" = import ./rclone-onedrive-template.nix { 
    inherit pkgs;
    user = "jess";
    uid = config.users.users."jess".uid;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Add neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    configure = {
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ vim-nix ];
      };
    };
  };

  # Add starship
  programs.starship = {
    enable = true;
    settings = {
      username = {
        format = "[$user]($style)";
        show_always = true;
      };
      hostname = {
        format = "@[$hostname]($style) ";
        ssh_only = true;
      };
      shlvl = {
        disabled = false;
        symbol = " 🐚";
        threshold = 1;
      };
      cmd_duration.disabled = true;
      directory = {
        format = " [$path]($style)[$read_only]($read_only_style) ";
        truncate_to_repo = false;
        truncation_symbol = "…/";
      };
      git_branch.format = " [$symbol$branch]($style) ";
    };
  };

  # Add steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Add packages that don't take special configuration
  environment.systemPackages = with pkgs; [
    git
    ripgrep
    piper
    virt-manager
    easyeffects
    (neovim-qt.override { neovim = config.programs.neovim.finalPackage; })

    # kde themes, effects, etc.
    plasma5Packages.bismuth
    kate
    (kde-rounded-corners.overrideAttrs (super: {
      version = "unstable-2022-12-20";
      src = fetchFromGitHub {
        owner = "matinlotfali";
        repo = "KDE-Rounded-Corners";
        rev = "cb6c31f5b58bf61a0c737669d2a0511748b7bfa6";
        hash = "sha256-ubocO0Vr3g5kIuGNV6vH+ySP42gFps9gPi5d3EpQVFY=";
      };
    }))
    sddm-sugar-light  # from overlay
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "22.11";

}
