{
  lib,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostId = "8425e349";

  services.openssh.openFirewall = lib.mkForce false;

  services.tailscale.extraUpFlags = [ "--advertise-tags=tag:gaia" ];

  zramSwap.enable = true;
  zramSwap.memoryPercent = 250;

  # Check that this can be bumped before changing it
  system.stateVersion = "25.11";
}
