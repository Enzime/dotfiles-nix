{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "delta-nixos";

  hardware.cpu.intel.updateMicrocode = true;

  networking.interfaces.wlp4s0.useDHCP = true;

  services.udev.extraHwdb = ''
    evdev:name:AT Translated Set 2 keyboard:dmi:*
      KEYBOARD_KEY_3a=esc
  '';

  # Check that this can be bumped before changing it
  system.stateVersion = "21.05";
}
