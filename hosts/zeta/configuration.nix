{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.cpu.amd.updateMicrocode = true;

  networking.hostName = "zeta-nixos";

  networking.interfaces.eno1.useDHCP = true;

  i18n.defaultLocale = "en_AU.UTF-8";

  # GNOME runs Wayland by default
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Check that this can be bumped before changing it
  system.stateVersion = "21.05";
}
