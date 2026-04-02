{
  config,
  lib,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  networking.hostId = "8425e349";

  services.openssh.openFirewall = lib.mkForce false;

  zramSwap.enable = true;
  zramSwap.memoryPercent = 250;

  nix.distributedBuilds = true;

  # Use ssh-ng for trustless remote building of input-addressed derivations
  # i.e. not requiring remote user to be a trusted-user
  nix.buildMachines = [
    {
      protocol = "ssh-ng";
      hostName = "clan.lol";
      sshUser = "builder";
      sshKey = config.clan.core.vars.generators.nix-remote-build.files.key.path;
      system = "x86_64-linux";
      supportedFeatures = [
        "kvm"
        "benchmark"
        "big-parallel"
        "nixos-test"
        "uid-range"
      ];
      maxJobs = 96;
    }
  ];

  # Check that this can be bumped before changing it
  system.stateVersion = "25.11";
}
