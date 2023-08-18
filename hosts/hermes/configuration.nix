{ user, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  boot.extraModprobeConfig = ''
    options hid_apple swap_opt_cmd=1
  '';

  # We don't use dmi:* as there's no DMI data
  # Alternatively evdev:input:b001Cv05ACp0281e0935-* from /sys/class/input/event3/device/modalias
  services.udev.extraHwdb = ''
    evdev:name:Apple Internal Keyboard / Trackpad:*
      KEYBOARD_KEY_70039=esc
  '';

  # GDM is currently broken
  services.xserver.displayManager.gdm.enable = lib.mkForce false;
  services.xserver.displayManager.lightdm.enable = true;

  environment.etc."nixos".source =
    lib.mkForce "/home/${user}/Code/private-dotfiles";

  nix.registry.dotfiles.to = {
    type = "git";
    url = "file:///home/${user}/dotfiles";
  };

  nix.registry.d.to = lib.mkForce {
    type = "git";
    url = "file:///home/${user}/Code/private-dotfiles";
  };

  networking.networkmanager.wifi.backend = "iwd";

  # Check that this can be bumped before changing it
  system.stateVersion = "23.11";
}

