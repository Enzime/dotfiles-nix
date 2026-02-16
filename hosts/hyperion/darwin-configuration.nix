{ user, config, pkgs, ... }:

{
  networking.knownNetworkServices = [ "Wi-Fi" ];

  nix.registry.ln.to = {
    type = "git";
    url = "file://${config.users.users.${user}.home}/Code/nixpkgs";
  };
  nix.registry.lnd.to = {
    type = "git";
    url = "file://${config.users.users.${user}.home}/Code/nix-darwin";
  };

  system.defaults.dock.persistent-apps = [
    "/Applications/Firefox.app"
    "${pkgs.ghostty-bin}/Applications/Ghostty.app"
    "${pkgs.vscode}/Applications/Visual Studio Code.app"
    "${pkgs.spotify}/Applications/Spotify.app"
    "/Applications/Element.app"
  ];

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
      supportedFeatures =
        [ "kvm" "benchmark" "big-parallel" "nixos-test" "uid-range" ];
      maxJobs = 96;
    }
    {
      protocol = "ssh-ng";
      hostName = "build01.clan.lol";
      sshUser = "builder";
      sshKey = config.clan.core.vars.generators.nix-remote-build.files.key.path;
      system = "aarch64-linux";
      supportedFeatures =
        [ "kvm" "benchmark" "big-parallel" "nixos-test" "uid-range" ];
      maxJobs = 96;
    }
  ];

  system.stateVersion = 6;
}
