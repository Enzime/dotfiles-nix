{ user, keys, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  systemd.network.enable = true;
  age.secrets.network = {
    file = ../../secrets/network_apollo.age;
    path = "/etc/systemd/network/20-wired.network";
    owner = "systemd-network";
  };

  boot.cleanTmpDir = true;
  zramSwap.enable = true;
  zramSwap.memoryPercent = 90;
  users.users.${user} = {
    openssh.authorizedKeys.keys = builtins.attrValues {
      inherit (keys.users) enzime_phi;
    };
  };

  # Check that this can be bumped before changing it
  system.stateVersion = "22.05";
}
