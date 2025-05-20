{
  imports = [ "acme" ];

  nixosModule = { user, options, config, pkgs, lib, ... }:
    let hostname = "nextcloud.enzim.ee";
    in {
      imports = [{
        config = lib.optionalAttrs (options ? clan) {
          clan.core.vars.generators.acme-zoneee = {
            share = true;
            prompts.api-user.persist = true;
            prompts.api-key.persist = true;

            files.api-user.deploy = false;
            files.api-key.deploy = false;
            files.credentials = { };

            script = ''
              touch "$out"/credentials
              printf >>"$out"/credentials "ZONEEE_API_USER=%s\n" "$(cat "$prompts"/api-user)"
              printf >>"$out"/credentials "ZONEEE_API_KEY=%s\n" "$(cat "$prompts"/api-key)"
            '';
          };

          clan.core.vars.generators.nextcloud = {
            files.admin-password = { };
            runtimeInputs = [ pkgs.coreutils pkgs.xkcdpass ];
            script = ''
              xkcdpass --numwords 4 --random-delimiters --valid-delimiters='1234567890!@#$%^&*()-_+=,.<>/?' --case random | tr -d "\n" > $out/admin-password
            '';
          };
        };
      }];

      services.nextcloud.enable = true;
      services.nextcloud.package = pkgs.nextcloud31;
      services.nextcloud.hostName = hostname;
      services.nextcloud.settings.trusted_domains = [ "reflector.enzim.ee" ];
      services.nextcloud.https = true;

      services.nextcloud.config = {
        dbtype = "sqlite";
        adminuser = "admin";
        adminpassFile =
          config.clan.core.vars.generators.nextcloud.files.admin-password.path;
      };

      security.acme.certs.${hostname} = {
        dnsProvider = "zoneee";
        credentialsFile =
          config.clan.core.vars.generators.acme-zoneee.files.credentials.path;
      };

      services.nginx.virtualHosts.${hostname} = {
        forceSSL = true;
        useACMEHost = hostname;
      };

      users.users.${user}.extraGroups = [ "nextcloud" ];
    };
}
