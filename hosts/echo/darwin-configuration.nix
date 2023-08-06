{ keys, ... }:

{
  networking.knownNetworkServices = [ "Ethernet" ];

  nix.distributedBuilds = true;

  nix.buildMachines = [{
    hostName = "chi-linux-builder";
    sshUser = "builder";
    sshKey = "/etc/ssh/ssh_host_ed25519_key";
    system = "aarch64-linux";
    supportedFeatures = [ "kvm" "benchmark" "big-parallel" ];
    publicHostKey =
      "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUpCV2N4Yi9CbGFxdDFhdU90RStGOFFVV3JVb3RpQzVxQkorVXVFV2RWQ2Igcm9vdEBuaXhvcwo=";
  }];

  nix.settings.trusted-public-keys = [ keys.signing.chi-linux-builder ];

  nix.settings.min-free = 1024 * 1024 * 1024;
  nix.settings.max-free = 3 * 1024 * 1024 * 1024;
}
