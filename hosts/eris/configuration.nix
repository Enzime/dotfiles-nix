{ user, keys, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub.enable = true;

  networking.hostId = "536c3bf5";

  services.tailscale.extraSetFlags = [ "--advertise-exit-node" ];
  services.tailscale.extraUpFlags = [ "--advertise-tags" "tag:eris" ];
  services.tailscale.useRoutingFeatures = "server";

  zramSwap.enable = true;
  zramSwap.memoryPercent = 250;

  users.users.${user} = {
    openssh.authorizedKeys.keys =
      builtins.attrValues { inherit (keys.users) nathan; };
  };

  # Check that this can be bumped before changing it
  system.stateVersion = "23.11";
}
