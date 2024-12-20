{ keys, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostId = "980bd196";

  services.openssh.openFirewall = lib.mkForce false;

  services.tailscale.authKeyFile = "/tmp/tailscale.key";

  zramSwap.enable = true;
  zramSwap.memoryPercent = 250;

  users.users.builder = {
    openssh.authorizedKeys.keys =
      builtins.attrValues { inherit (keys.hosts) echo; };
  };

  # Check that this can be bumped before changing it
  system.stateVersion = "23.11";
}
