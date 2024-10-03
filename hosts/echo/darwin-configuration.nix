{ ... }:

{
  networking.knownNetworkServices = [ "Ethernet" ];

  ids.gids.nixbld = 30000;

  nix.settings.secret-key-files = [ "/etc/nix/key" ];

  nix.distributedBuilds = true;

  nix.buildMachines = [{
    # Use ssh-ng for trustless remote building of input-addressed derivations
    # i.e. not requiring remote user to be a trusted-user
    protocol = "ssh-ng";
    hostName = "chi-linux-builder";
    sshUser = "builder";
    sshKey = "/etc/ssh/ssh_host_ed25519_key";
    system = "aarch64-linux";
    supportedFeatures = [ "kvm" "benchmark" "big-parallel" ];
    publicHostKey =
      "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUpCV2N4Yi9CbGFxdDFhdU90RStGOFFVV3JVb3RpQzVxQkorVXVFV2RWQ2Igcm9vdEBuaXhvcwo=";
  }];

  system.defaults.dock.persistent-apps = [
    "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"
    "/System/Applications/System Settings.app"
  ];

  system.stateVersion = 5;
}
