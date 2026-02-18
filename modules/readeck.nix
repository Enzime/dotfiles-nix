{
  nixosModule =
    {
      options,
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        {
          config = lib.optionalAttrs (options ? clan) {
            clan.core.vars.generators.readeck = {
              files.env = { };
              runtimeInputs = [ pkgs.openssl ];
              script = ''
                echo "READECK_SECRET_KEY=$(openssl rand -base64)" 48 >> $out/env
              '';
            };

            clan.core.vars.generators.readeck-user = {
              files.password.deploy = false;
              files.password-hash = { };
              runtimeInputs = [
                pkgs.coreutils
                pkgs.xkcdpass
                pkgs.openssl
              ];
              script = ''
                xkcdpass --numwords 4 --random-delimiters --valid-delimiters='1234567890!@#$%^&*()-_+=,.<>/?' --case random | tr -d "\n" > "$out"/password
                openssl passwd -6 -in "$out"/password > "$out"/password-hash
              '';
            };
          };
        }
      ];

      services.readeck.enable = true;
      services.readeck.settings.server.port = 8000;
      services.readeck.environmentFile = config.clan.core.vars.generators.readeck.files.env.path;

      services.nginx.virtualHosts."readeck.enzim.ee" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.readeck.settings.server.port}";
        };
      };

      systemd.services.readeck-user = {
        description = "Create Readeck user";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        before = [ "readeck.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          inherit (config.systemd.services.readeck.serviceConfig)
            StateDirectory
            WorkingDirectory
            DynamicUser
            ;
          LoadCredential = "password-hash:${config.clan.core.vars.generators.readeck-user.files.password-hash.path}";
          ExecStart = pkgs.writeShellScript "readeck-user" ''
            ${lib.getExe config.services.readeck.package} user -u Enzime -p "$(cat "$CREDENTIALS_DIRECTORY"/password-hash)"
          '';
        };
      };

      preservation.preserveAt."/persist".directories = [ "/var/lib/private/readeck" ];
    };
}
