{
  config,
  pkgs,
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

  services.matrix-synapse.settings.federation_domain_whitelist = [ ];

  services.mautrix-signal.enable = true;
  services.mautrix-signal.settings = {
    network.displayname_template = ''{{or .Nickname .ContactName .ProfileName .PhoneNumber "Unknown user"}} (Signal)'';

    bridge = {
      permissions = {
        "test.enzim.ee" = "user";
        "@enzime:test.enzim.ee" = "admin";
      };

      bridge_matrix_leave = false;
      mute_only_on_create = false;
      personal_filtering_spaces = false;
    };

    homeserver = {
      address = "http://localhost:8008";
    };

    logging.min_level = "debug";
  };

  nixpkgs.config.permittedInsecurePackages =
    assert pkgs.mautrix-signal.version == "26.02";
    [ "olm-3.2.16" ];

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
