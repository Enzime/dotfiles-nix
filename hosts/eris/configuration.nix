{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.forceInstall = true;
  boot.loader.grub.device = "nodev";
  boot.loader.timeout = 10;

  networking.interfaces.enp0s4.useDHCP = true;

  users.users.human = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHZcON5uabdGPUp5Sf161wShGEwhNklD8w50f6EnkPgo nathan@m-s11"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILzD/3cOhlqe8NVEruSUnPSnG1GbmX8SgTbVGLFHMa7g enzime@phinixos"
    ];
  };

  # Check that this can be bumped before changing it
  system.stateVersion = "21.05";
}
