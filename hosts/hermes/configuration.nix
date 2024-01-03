{ user, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  boot.extraModprobeConfig = ''
    options hid_apple swap_opt_cmd=1
  '';

  services.udev.extraRules = ''
    KERNEL=="macsmc-battery", SUBSYSTEM=="power_supply", ATTR{charge_control_end_threshold}="80", ATTR{charge_control_start_threshold}="70"
  '';

  # We don't use dmi:* as there's no DMI data
  # Alternatively evdev:input:b001Cv05ACp0281e0935-* from /sys/class/input/event3/device/modalias
  services.udev.extraHwdb = ''
    evdev:name:Apple Internal Keyboard / Trackpad:*
      KEYBOARD_KEY_70039=esc
  '';

  services.logind.extraConfig = lib.mkForce ''
    HandlePowerKey=lock
    HandleLidSwitch=lock
    HandleLidSwitchExternalPower=lock
  '';

  # GDM is currently broken
  services.xserver.displayManager.gdm.enable = lib.mkForce false;
  services.xserver.displayManager.lightdm.enable = true;

  nix.distributedBuilds = true;

  nix.buildMachines = [{
    hostName = "aether";
    sshUser = "builder";
    sshKey = "/etc/ssh/ssh_host_ed25519_key";
    system = "aarch64-linux";
    supportedFeatures = [ "kvm" "benchmark" "big-parallel" "nixos-test" ];
    publicHostKey =
      "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU5IejJTWjBjTzdsQlFyenVHclkySGNVczFSMnR5N3M5RnlXelNrSnh0OXkK";
  }];

  nix.registry.lnas.to = {
    type = "git";
    url = "file:///home/${user}/Code/nixos-apple-silicon";
  };

  networking.networkmanager.wifi.backend = "iwd";

  programs.captive-browser.interface = "wlan0";

  # Check that this can be bumped before changing it
  system.stateVersion = "23.11";
}
