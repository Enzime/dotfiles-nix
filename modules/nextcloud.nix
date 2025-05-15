{
  imports = [ "acme" ];

  nixosModule = { user, config, pkgs, ... }:
    let hostname = "nextcloud.enzim.ee";
    in {
      services.nextcloud.enable = true;
      services.nextcloud.package = pkgs.nextcloud31;
      services.nextcloud.hostName = hostname;
      services.nextcloud.settings.trusted_domains = [ "reflector.enzim.ee" ];
      services.nextcloud.https = true;

      age.secrets.nextcloud.file = ../secrets/nextcloud.age;
      age.secrets.nextcloud.owner = "nextcloud";

      services.nextcloud.config = {
        dbtype = "sqlite";
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
    };
}
