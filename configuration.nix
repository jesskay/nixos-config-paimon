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

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable gnome-settings-daemon udev rules
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

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
      (wrapFirefox firefox-unwrapped {
        forceWayland = true;
        cfg.enableGnomeExtensions = true;
      })
      firefox-wayland
      ((discord.overrideAttrs (super: {  # modify shortcut at the end of the install phase to force 80ms pulse latency
        installPhase = (super.installPhase or "") + ''
          # copy the content out of the symlinked applications dir so we can actually work with it
          # (otherwise it's in a different derivation and perms won't let us touch it)
          mkdir -p $out/share/applications-copy
          cp -a $out/share/applications/* $out/share/applications-copy/
          rm $out/share/applications
          mv $out/share/applications-copy $out/share/applications

          # patch the desktop item in place
          sed 's/^Exec=/Exec=env PULSE_LATENCY_MSEC=200 /' -i $out/share/applications/discord.desktop
          '';
      })).override {  # override to use the same nss as firefox
        # will need updating if firefox ever uses a non-latest nss
        # obsoleted if/when https://github.com/NixOS/nixpkgs/pull/186603 lands
        nss = nss_latest;
      })
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
      character.error_symbol = "💥";
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

    # GNOME
    gnome.gnome-terminal
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-panel
    gnomeExtensions.no-overview
    gnomeExtensions.rclone-manager
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "22.05";

}
