{
  imports = [ "acme" ];

  nixosModule =
    {
      user,
      options,
      config,
      pkgs,
      lib,
      ...
    }:
    let
      hostname = "nextcloud.enzim.ee";
    in
    {
      imports = [
        {
          config = lib.optionalAttrs (options ? clan) {
            clan.core.vars.generators.nextcloud = {
              files.admin-password = { };
              runtimeInputs = [
                pkgs.coreutils
                pkgs.xkcdpass
              ];
              script = ''
                xkcdpass --numwords 4 --random-delimiters --valid-delimiters='1234567890!@#$%^&*()-_+=,.<>/?' --case random | tr -d "\n" > $out/admin-password
              '';
            };
          };
        }
      ];

      services.nextcloud.enable = true;
      services.nextcloud.package = pkgs.nextcloud32;
      services.nextcloud.hostName = hostname;
      services.nextcloud.settings.trusted_domains = [ "reflector.enzim.ee" ];
      services.nextcloud.https = true;

      services.nextcloud.config = {
        dbtype = "sqlite";
        adminuser = "admin";
        adminpassFile = config.clan.core.vars.generators.nextcloud.files.admin-password.path;
      };

      services.nginx.virtualHosts.${hostname} = {
        forceSSL = true;
        enableACME = true;
      };

      users.users.${user}.extraGroups = [ "nextcloud" ];
    };
}
