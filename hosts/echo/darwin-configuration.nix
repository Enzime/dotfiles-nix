{ ... }:

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

  system.defaults.dock.persistent-apps = [
    "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"
    "/System/Applications/System Settings.app"
  ];
}
