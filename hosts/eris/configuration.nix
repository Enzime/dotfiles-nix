{ user, keys, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.forceInstall = true;
  boot.loader.grub.device = "nodev";
  boot.loader.timeout = 10;

  networking.interfaces.enp0s4.useDHCP = true;

  users.users.${user} = {
    openssh.authorizedKeys.keys = builtins.attrValues {
      inherit (keys.users) enzime_phi nathan;
    };
  };

  # Check that this can be bumped before changing it
  system.stateVersion = "21.05";
}
