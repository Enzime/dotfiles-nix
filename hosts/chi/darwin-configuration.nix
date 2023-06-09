{ user, ... }:

{
  networking.knownNetworkServices = [ "Ethernet" "Wi-Fi" ];

  nix.registry.ln.to = {
    type = "git";
    url = "file:///Users/${user}/Projects/nixpkgs";
  };
  nix.registry.lnd.to = {
    type = "git";
    url = "file:///Users/${user}/Projects/nix-darwin";
  };

  nix.linux-builder.enable = true;
  nix.settings.extra-trusted-users = [ user ];
}
