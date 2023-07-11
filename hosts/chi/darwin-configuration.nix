{ user, pkgs, ... }:

{
  networking.knownNetworkServices = [ "Ethernet" "Wi-Fi" ];

  # Start garbage collection when less than 5 GiB free and stop once 15 GiB is free
  nix.settings.auto-optimise-store = true;
  nix.settings.min-free = 5 * 1024 * 1024 * 1024;
  nix.settings.max-free = 15 * 1024 * 1024 * 1024;

  launchd.user.agents.echo = {
    serviceConfig.ProgramArguments =
      [ "${pkgs.utm}/bin/utmctl" "start" "echo" ];
    serviceConfig.RunAtLoad = true;
  };

  nix.registry.ln.to = {
    type = "git";
    url = "file:///Users/${user}/Projects/nixpkgs";
  };
  nix.registry.lnd.to = {
    type = "git";
    url = "file:///Users/${user}/Projects/nix-darwin";
  };
}
