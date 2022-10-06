{ user, lib, ... }: {
  networking.knownNetworkServices = [ "Wi-Fi" ];

  nix.registry.ln.to = { type = "git"; url = "file:///Users/${user}/Code/nixpkgs"; };
  nix.registry.lnd.to = { type = "git"; url = "file:///Users/${user}/Code/nix-darwin"; };

  services.synergy.client.enable = true;
  services.synergy.client.serverAddress = "phi-nixos.local";
  services.synergy.client.tls = true;
}
