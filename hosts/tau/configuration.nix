{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.enableRedistributableFirmware = true;

  services.udev.extraHwdb = ''
    evdev:name:Microsoft Surface * Keyboard:dmi:*
      KEYBOARD_KEY_70039=esc

    evdev:name:USB-HID Keyboard:dmi:*
      KEYBOARD_KEY_70039=esc
  '';

  # Check that this can be bumped before changing it
  system.stateVersion = "22.05";
}
