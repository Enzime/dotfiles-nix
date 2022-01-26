{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.cpu.intel.updateMicrocode = true;

  networking.interfaces.wlp170s0.useDHCP = true;

  # Check that this can be bumped before changing it
  system.stateVersion = "22.05";
}
