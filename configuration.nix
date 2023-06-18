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

  # Disable wait-online service as it breaks on rebuild sometimes and I don't use it
  systemd.services.NetworkManager-wait-online.enable = false;

  # Enable wake-on-lan
  networking.interfaces."enp34s0".wakeOnLan.enable = true;

  # Enable tailscale
  services.tailscale.enable = true;
  networking.firewall = {
    trustedInterfaces = [ "tailscale0" "enp34s0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    # Loosen reverse path checking, to not break tailscale exit nodes
    checkReversePath = "loose";
  };

  services.fwupd.enable = true;

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
    theme = "We10XOS";
    settings.General.InputMethod = "";  # disable virtual keyboard
  };
  services.xserver.desktopManager.plasma5.enable = true;

  # Enable remote plasma
  services.xrdp = {
    enable = true;
    defaultWindowManager = "startplasma-x11";
    openFirewall = true;
  };

  # Enable dconf to ensure GTK themes are applied under Wayland
  programs.dconf.enable = true;

  # Enable KDE Connect
  programs.kdeconnect.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "custom";
    xkbVariant = "";
    xkbOptions = "";
    extraLayouts."custom" = {
      description = "UK layout with Caps as LCtrl";
      languages = [ "eng" ];
      symbolsFile = "${pkgs.xkb-symbols-gb-capsctrl}/share/X11/xkb/symbols/custom";
    };
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable ratbagd to configure gaming mice
  services.ratbagd.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

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
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBNlbD3M/P430r5JgrbriC6H2dKUSuIflEouucsNwNR0cWQVYorpyn/hR6APsav6q9HaiHQPramKwCP7e2/3N2us= ShellFish@iPhone-30102022"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBoZB9gm4v2V+ucQdcB5bET43xvWRuSbqSAyxeBmbzoh ipadmini"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGZh89nwHqzxMB8vxQiO2upejx/tcTLxeZqnlOARyK15 shortcuts-iphone"
    ];
  };

  # Enable onedrive service
  services.onedrive.enable = true;

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
  environment.systemPackages = (with pkgs; [
    git
    ripgrep
    piper
    virt-manager
    virtiofsd
    easyeffects

    # kde themes, effects, etc.
    kate
    we10xos-dark  # from overlay
  ]) ++ (with pkgs.libsForQt5; [
    lightly
    qtstyleplugin-kvantum
    ark
  ]);

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.Macs = [
      # offer the 6 MACs recommended by https://blog.stribik.technology/2015/01/04/secure-secure-shell.html
      #  and https://infosec.mozilla.org/guidelines/openssh#modern-openssh-67
      #  (NixOS as of 23.05 only offers ETM options, but some devices I use still only use MTE)
      "hmac-sha2-512-etm@openssh.com"
      "hmac-sha2-256-etm@openssh.com"
      "umac-128-etm@openssh.com"
      "hmac-sha2-512"
      "hmac-sha2-256"
      "umac-128@openssh.com"
    ];
  };

  system.stateVersion = "23.11";

}
