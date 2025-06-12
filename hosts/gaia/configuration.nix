{ lib, ... }:

{
  imports = [ ./disko.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostId = "5d07acb6";

  services.openssh.openFirewall = lib.mkForce false;

  services.tailscale.authKeyFile = "/tmp/tailscale.key";

  zramSwap.enable = true;
  zramSwap.memoryPercent = 250;

  # Check that this can be bumped before changing it
  system.stateVersion = "25.11";
}
