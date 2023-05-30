{ user, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  services.fwupd.enable = true;
  services.fwupd.extraRemotes = [ "lvfs-testing" ];
  environment.etc."fwupd/uefi_capsule.conf" = lib.mkForce {
    source =
      pkgs.runCommand "fwupd-uefi-capsule-update-on-disk-disable.conf" { } ''
        sed "s,^#DisableCapsuleUpdateOnDisk=true,DisableCapsuleUpdateOnDisk=true," \
        "${pkgs.fwupd}/etc/fwupd/uefi_capsule.conf" > "$out"
      '';
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.cpu.intel.updateMicrocode = true;

  networking.interfaces.wlp170s0.useDHCP = true;

  nix.registry.ln.to = {
    type = "git";
    url = "file:///home/${user}/Code/nixpkgs";
  };

  services.tailscale.useRoutingFeatures = "client";

  services.fprintd.enable = true;

  # Check that this can be bumped before changing it
  system.stateVersion = "22.05";
}
