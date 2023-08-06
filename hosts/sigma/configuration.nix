{ user, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  services.fwupd.enable = true;
  services.fwupd.extraRemotes = [ "lvfs-testing" ];
  environment.etc."fwupd/fwupd.conf" = lib.mkForce {
    source =
      pkgs.runCommand "fwupd-with-uefi-capsule-update-on-disk-disable.conf"
      { } ''
        cat ${pkgs.fwupd}/etc/fwupd/fwupd.conf > $out
        cat >> $out <<EOF

        [uefi_capsule]
        DisableCapsuleUpdateOnDisk=true
        EOF
      '';
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.cpu.intel.updateMicrocode = true;

  nix.registry.ln.to = {
    type = "git";
    url = "file:///home/${user}/Code/nixpkgs";
  };

  services.tailscale.useRoutingFeatures = "client";

  services.fprintd.enable = true;

  # Check that this can be bumped before changing it
  system.stateVersion = "22.05";
}
