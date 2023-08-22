{
  imports = [ "acme" ];

  nixosModule = { user, options, config, pkgs, ... }:
    let hostname = "nextcloud.enzim.ee";
    in {
      services.nextcloud.enable = true;
      services.nextcloud.package = pkgs.nextcloud27;
      services.nextcloud.hostName = hostname;
      services.nextcloud.config.extraTrustedDomains = [ "reflector.enzim.ee" ];
      services.nextcloud.https = true;

      age.secrets.nextcloud.file = ../secrets/nextcloud.age;
      age.secrets.nextcloud.owner = "nextcloud";

      services.nextcloud.config = {
        adminuser = "admin";
        adminpassFile = config.age.secrets.nextcloud.path;
      };

      age.secrets.acme_zoneee.file = ../secrets/acme_zoneee.age;

      security.acme.certs.${hostname} = {
        dnsProvider = "zoneee";
        credentialsFile = config.age.secrets.acme_zoneee.path;
      };

      services.nginx.virtualHosts.${hostname} = {
        forceSSL = true;
        useACMEHost = hostname;
      };

      users.users.${user}.extraGroups = [ "nextcloud" ];

      # Change `system.stateVersion` to 22.11+ or wait for this option to account for running Nextcloud 26
      services.nextcloud.enableBrokenCiphersForSSE =
        assert (options.services.nextcloud.enableBrokenCiphersForSSE.default
          == true);
        false;
    };
}
