{ ... }:

{
  networking.knownNetworkServices = [ "Ethernet" ];

  nix.settings.auto-optimise-store = true;
  nix.settings.min-free = 1024 * 1024 * 1024;
  nix.settings.max-free = 3 * 1024 * 1024 * 1024;
}
