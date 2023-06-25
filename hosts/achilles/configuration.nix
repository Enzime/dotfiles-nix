{ lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  services.udev.extraHwdb = ''
    evdev:name:Apple Inc. Virtual USB Keyboard:dmi:*
      KEYBOARD_KEY_700e2=leftmeta
      KEYBOARD_KEY_700e3=leftalt
  '';

  services.xserver.displayManager.defaultSession = lib.mkForce "none+i3";

  services.tailscale.useRoutingFeatures = "client";

  # Clipboard sharing
  services.spice-vdagentd.enable = true;

  # Check that this can be bumped before changing it
  system.stateVersion = "23.11";
}
