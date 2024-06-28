{ user, pkgs, lib, ... }:

{
  networking.knownNetworkServices = [ "Ethernet" "Wi-Fi" ];

  launchd.user.agents.echo = {
    serviceConfig.ProgramArguments =
      [ (lib.getExe' pkgs.utm "utmctl") "start" "echo" ];
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
