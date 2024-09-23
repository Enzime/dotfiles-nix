{ ... }:

{
  networking.knownNetworkServices = [ "Ethernet" ];

  ids.gids.nixbld = 30000;

  nix.settings.secret-key-files = [ "/etc/nix/key" ];

  nix.distributedBuilds = true;

  nix.buildMachines = [{
    # Use ssh-ng for trustless remote building of input-addressed derivations
    # i.e. not requiring builder@aether to be a trusted-user
    protocol = "ssh-ng";
    hostName = "aether";
    sshUser = "builder";
    sshKey = "/etc/ssh/ssh_host_ed25519_key";
    system = "aarch64-linux";
    supportedFeatures =
      [ "kvm" "benchmark" "big-parallel" "gccarch-armv8-a" "nixos-test" ];
    publicHostKey =
      "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU5IejJTWjBjTzdsQlFyenVHclkySGNVczFSMnR5N3M5RnlXelNrSnh0OXkK";
  }];

  system.defaults.dock.persistent-apps = [
    "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"
    "/System/Applications/System Settings.app"
  ];

  system.stateVersion = 5;
}
