{ config, pkgs, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Enable systemd to start in initrd (stage 1) rather than only in
  # stage 2 - allows some services to come up sooner
  boot.initrd.systemd.enable = true;

  # Quiet boot and plymouth graphical splash
  boot.kernelParams = [ "quiet" ];
  boot.plymouth.enable = true;
  boot.plymouth.themePackages = [ pkgs.adi1090x-plymouth ];
  boot.plymouth.theme = "hexa_retro";

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

  # Enable emulated aarch64 for mobile-nixos stage 2 builds
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

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

  # Enable podman
  virtualisation.podman.enable = true;

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

  # Enable waydroid
  virtualisation.waydroid.enable = true;

  # Enable dconf to ensure GTK themes are applied under Wayland
  programs.dconf.enable = true;

  # Enable KDE Connect
  programs.kdeconnect.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "custom";
    variant = "";
    options = "";
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
  environment.etc."pipewire/revert-min-quantum.d/99-custom.conf".text = ''
    # revert to the pre-0.3.67 minimums
    pulse.properties = {
        pulse.min.req       = 256/48000   # 5ms
        pulse.min.frag      = 256/48000   # 5ms
        pulse.min.quantum   = 256/48000   # 5ms
    }
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jess = {
    isNormalUser = true;
    description = "Jessica Kay";
    uid = 1000;  # set explicitly for consistency
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "adbusers"
    ];
    packages = with pkgs; [
      firefox
      discord-fixup  # from overlay
      keepassxc
    ];
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBNlbD3M/P430r5JgrbriC6H2dKUSuIflEouucsNwNR0cWQVYorpyn/hR6APsav6q9HaiHQPramKwCP7e2/3N2us= ShellFish@iPhone-30102022"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD5rgzxdtDKibJMpmmUMYBb8EWeZA6x1onGxwR24OzFs4gSfMkge5SsInNbaLXZXDkDWGXo5+A434NdZ3IiIt/5wmn1M6i0z4mGxlKNlbmgcp2fHE+YwfD474kZfKhRLlx9KPFIvRj/OJJFgIRmMxbFYNPP3kaftvkNubjS6zoSAZf7bg8YGdeh5IJULMrILaVojYledkU1y6Fg/Avj0RjfhIhfm0JXuQcYpYhFN8hcN79KXm+HInVQrcOyUNQ9ut3YwXZTiulbiduNGKnSCWGcBKBTIDIpI05U0FKe4HZ3AY8AAIztHlKC180tB27deeNppv1EXWxweBrpvAkOS/59/Y1YkW5V7DjWT7jmU6Dzl04/t1Yx2Yk+V3awoo1KVJ94WjPadUdTfFWqxBFx2tsxOTCDfoQE/128vZtHTXME+O+KqHKeQd3w4zIvzWzAUdHzHCVEIw7oyKQD9If7D3kZ2yRd/V4a0o/ahxhiMAZeBI+C2iX4VY0Rv+Ad5o2fRMwfr9EGwCLs5caTsAan4aP9S2fec3UUH0SKe0iLQ18KGXUdHljL2sxplW51vbWi6IVWnBgrczHQZYXRwzeLcMIyqA/W0Fyin2gD+sg22KXRjcA1E1wL/ZPk/CR/hAkFsQiOY89KKIfsTz/3ezymZvL69M2/LV5aDG1XbdypwyR8nw== ShellFish@iPad-31072023"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBoZB9gm4v2V+ucQdcB5bET43xvWRuSbqSAyxeBmbzoh ipadmini"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGZh89nwHqzxMB8vxQiO2upejx/tcTLxeZqnlOARyK15 shortcuts-iphone"
    ];
  };

  # Enable onedrive service
  services.onedrive.enable = true;

  # Allow unfree packages, and electron 25.9.0 for Obsidian
  # (optional on specific obsidian version so this can be re-evaluated when
  #  obsidian updates, and hopefully depends on a non-EOL electron)
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages =
    	pkgs.lib.optional (pkgs.obsidian.version == "1.5.3") "electron-25.9.0";
  };

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

  # Add ADB and Fastboot and udev rules
  programs.adb.enable = true;

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

  # enable joycond
  services.joycond.enable = true;

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

  system.stateVersion = "24.05";

}
