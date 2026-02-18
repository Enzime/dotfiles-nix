{
  imports = [ "acme" ];

  nixosModule =
    { config, ... }:
    let
      hostname = "reflector.enzim.ee";
    in
    {
      services.nginx.enable = true;
      services.nginx.recommendedTlsSettings = true;
      services.nginx.recommendedOptimisation = true;
      services.nginx.recommendedGzipSettings = true;

      # Forwards the Host header which is required for Nextcloud
      services.nginx.recommendedProxySettings = true;

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      services.nginx.virtualHosts.${hostname} = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/".proxyPass = "https://nextcloud.enzim.ee";
        };
      };
      services.nginx.clientMaxBodySize = config.services.nextcloud.maxUploadSize;
    };
}
