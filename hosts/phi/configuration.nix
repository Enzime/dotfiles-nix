{ config, user, keys, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.netbootxyz.enable = true;

  hardware.cpu.amd.updateMicrocode =
    lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 true;

  networking.nameservers = [ "1.1.1.1" ];
  networking.dhcpcd.extraConfig = ''
    nohook resolv.conf
  '';

  nix.registry.ln.to = {
    type = "git";
    url = "file:///home/${user}/nix/nixpkgs";
  };

  # Install firmware-linux-nonfree (includes Navi10 drivers)
  hardware.enableRedistributableFirmware = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable FreeSync
  services.xserver.deviceSection = ''
    Option "VariableRefresh" "true"
  '';

  # LWJGL 2 doesn't support modelines with text after WxH
  services.xserver.xrandrHeads = [{
    output = "DisplayPort-0";
    primary = true;
    monitorConfig = ''
      ModeLine "3440x1441"  1086.75  3440 3744 4128 4816  1440 1443 1453 1568 -hsync +vsync
      Option "PreferredMode" "3440x1441"
    '';
  }];

  services.udev.extraHwdb = ''
    evdev:name:USB-HID Keyboard:dmi:*
      KEYBOARD_KEY_70039=esc
  '';

  security.pam.u2f.enable = true;
  security.pam.u2f.settings.cue = true;
  security.pam.u2f.settings.authfile = pkgs.writeText "u2f-mappings" ''
    enzime:aZod0R2utyFHotPvicvh1Kj1hcrGjT+5cHAFdnB7X8lJoDpiPDGqEvYXOCEaFsudXD3YFFjEvBiinXsj90jcXg==,mQCyOcbnehUfXRb2Jp/y40ixSeE69rhLnD66Q8bA209moCJmGMwShxT2SIwHJZPGutNTfyqaht2XRK9x27CpLg==,es256,+presence%
  '';

  # For /mnt/phi on other systems
  users.users.${user} = {
    openssh.authorizedKeys.keys =
      builtins.attrValues { inherit (keys.hosts) sigma; };
  };

  services.nextcloud.home = "/data/Nextcloud";

  services.tailscale.extraSetFlags = [ "--advertise-exit-node" ];
  services.tailscale.useRoutingFeatures = "both";

  services.syncthing.dataDir = "${config.users.users.${user}.home}/sync";

  # Check that this can be bumped before changing it
  system.stateVersion = "22.05";
}
