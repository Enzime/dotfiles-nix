{ lib, ... }: {
  networking.knownNetworkServices = [ "Wi-Fi" ];

  services.synergy.client.enable = true;
  services.synergy.client.serverAddress = "phi-nixos.local";
  services.synergy.client.tls = true;
}
