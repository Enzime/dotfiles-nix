{ user, keys, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.forceInstall = true;
  boot.loader.grub.device = "nodev";
  boot.loader.timeout = 10;

  networking.interfaces.enp0s4.useDHCP = true;

  services.openssh.enable = lib.mkForce false;

  zramSwap.enable = true;
  zramSwap.memoryPercent = 250;

  # Check that this can be bumped before changing it
  system.stateVersion = "22.05";
}
