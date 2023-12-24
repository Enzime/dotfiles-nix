{ lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub.enable = true;

  networking.hostId = "536c3bf5";

  services.openssh.enable = lib.mkForce false;

  # `extraUpFlags` without `authKeyFile` isn't currently supported
  # services.tailscale.extraUpFlags = [ "--ssh" "--advertise-tags" "tag:eris" "--advertise-exit-node" ];
  services.tailscale.useRoutingFeatures = "server";

  zramSwap.enable = true;
  zramSwap.memoryPercent = 250;

  # Check that this can be bumped before changing it
  system.stateVersion = "23.11";
}
