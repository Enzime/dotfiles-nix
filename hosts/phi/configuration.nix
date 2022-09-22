{ config, user, keys, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.netbootxyz.enable = true;

  hardware.cpu.amd.updateMicrocode = true;

  # Living on the edge for Navi10
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.interfaces.enp34s0.useDHCP = true;

  networking.nameservers = [ "1.1.1.1" ];
  networking.dhcpcd.extraConfig = ''
    nohook resolv.conf
  '';

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  nix.registry.ln.to = { type = "git"; url = "file:///home/${user}/nix/nixpkgs"; };

  # Install firmware-linux-nonfree (includes Navi10 drivers)
  hardware.enableRedistributableFirmware = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  services.xserver.displayManager.gdm.autoSuspend = false;

  # Enable FreeSync
  services.xserver.deviceSection = ''
    Option "VariableRefresh" "true"
  '';

  # LWJGL 2 doesn't support modelines with text after WxH
  services.xserver.xrandrHeads = [ {
    output = "DisplayPort-2";
    primary = true;
    monitorConfig = ''
      ModeLine "2560x1441"  645.00  2560 2568 2600 2640  1440 1446 1454 1480 +hsync -vsync
      Option "PreferredMode" "2560x1441"
    '';
  }
  {
    output = "DisplayPort-1";
    monitorConfig = ''
      ModeLine "2560x1441"  645.00  2560 2568 2600 2640  1440 1446 1454 1480 +hsync -vsync
      Option "PreferredMode" "2560x1441"
      Option "RightOf" "DisplayPort-2"
    '';
  } ];

  security.pam.u2f.enable = true;
  security.pam.u2f.cue = true;
  security.pam.u2f.authFile = pkgs.writeText "u2f-mappings" ''
    enzime:aZod0R2utyFHotPvicvh1Kj1hcrGjT+5cHAFdnB7X8lJoDpiPDGqEvYXOCEaFsudXD3YFFjEvBiinXsj90jcXg==,mQCyOcbnehUfXRb2Jp/y40ixSeE69rhLnD66Q8bA209moCJmGMwShxT2SIwHJZPGutNTfyqaht2XRK9x27CpLg==,es256,+presence%
  '';

  users.users.${user} = {
    openssh.authorizedKeys.keys = builtins.attrValues {
      inherit (keys.users) enzime_sigma;
      inherit (keys.hosts) sigma;
    };
  };

  # Check that this can be bumped before changing it
  system.stateVersion = "21.05";
}
