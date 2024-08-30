{ user, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  services.fwupd.enable = true;
  services.fwupd.extraRemotes = [ "lvfs-testing" ];
  services.fwupd.uefiCapsuleSettings.DisableCapsuleUpdateOnDisk = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostId = "215212b4";

  hardware.cpu.intel.updateMicrocode = true;

  nix.registry.ln.to = {
    type = "git";
    url = "file:///home/${user}/Code/nixpkgs";
  };

  services.tailscale.useRoutingFeatures = "client";

  services.fprintd.enable = true;

  environment.persistence."/persist".directories = [ "/var/lib/fprint" ];

  programs.captive-browser.interface = "wlp170s0";

  # Check that this can be bumped before changing it
  system.stateVersion = "24.11";
}
