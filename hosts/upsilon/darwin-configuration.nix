{ user, ... }: {
  services.tailscale.overrideLocalDns = false;

  nix.registry.ln.to = {
    type = "git";
    url = "file:///Users/${user}/Code/nixpkgs";
  };
  nix.registry.lnd.to = {
    type = "git";
    url = "file:///Users/${user}/Code/nix-darwin";
  };
}
