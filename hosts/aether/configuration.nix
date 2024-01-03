{ config, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostId = "980bd196";

  services.openssh.openFirewall = lib.mkForce false;
  services.openssh.hostKeys = [{
    path = "/etc/ssh/ssh_host_ed25519_key";
    type = "ed25519";
  }];

  age.secrets.tailscale.file = ../../secrets/tailscale_aether.age;
  services.tailscale.authKeyFile = config.age.secrets.tailscale.path;

  zramSwap.enable = true;
  zramSwap.memoryPercent = 250;

  nix.settings.secret-key-files = [ "/etc/nix/key" ];

  # Check that this can be bumped before changing it
  system.stateVersion = "23.11";
}
