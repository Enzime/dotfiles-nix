{ user, ... }:

{
  networking.knownNetworkServices = [ "Wi-Fi" ];

  system.activationScripts.extraActivation.text = ''
    nvram StartupMute=%01
  '';

  nix.registry.ln.to = {
    type = "git";
    url = "file:///Users/${user}/Code/nixpkgs";
  };
  nix.registry.lnd.to = {
    type = "git";
    url = "file:///Users/${user}/Code/nix-darwin";
  };
}
