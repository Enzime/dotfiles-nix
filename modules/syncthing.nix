{
  nixosModule = { config, user, host, hostname, pkgs, lib, ... }: {
    services.syncthing.enable = true;
    services.syncthing.user = user;
    services.syncthing.group = "users";
    services.syncthing.dataDir =
      lib.mkDefault "${config.users.users.${user}.home}/Sync";
    services.syncthing.guiAddress = "0.0.0.0:8384";
    services.syncthing.overrideDevices = true;
    services.syncthing.overrideFolders = true;

    services.syncthing.settings = let
      mkDevice = { name, id, hostname ? name }: {
        ${name} = {
          inherit id;
          addresses = [ "tcp://${hostname}" ];
        };
      };

      mkFolder = { name, devices, ... }@v:
        let
          defaultArgs = lib.recursiveUpdate {
            path = "${config.services.syncthing.dataDir}/${name}";
          } v;
          mergedArgs = lib.recursiveUpdate defaultArgs devices.${hostname};
          args = mergedArgs // { devices = builtins.attrNames devices; };
          filteredArgs = builtins.removeAttrs args [ "name" ];
        in lib.optionalAttrs (devices ? ${hostname}) {
          ${name} = filteredArgs;
        };
    in {
      devices = lib.mkMerge (map mkDevice [
        {
          name = "hermes-macos";
          id =
            "QMDYKCN-4RSWSNS-QXKQREU-VTIEPQJ-X4RA4PX-KJJMMHU-DFWE6RS-BXNCEAF";
        }
        {
          name = "hermes-nixos";
          id =
            "GDV44DZ-DYPA2BZ-KFKVNPQ-RM2R7VT-GJAJG6V-IG25NEY-ZUXEOLL-V2B4DAH";
        }
        {
          name = "phi-nixos";
          id =
            "2YEN2S7-JYISWE4-UGUF6N4-7ZNSDNX-IKLEDGT-4WLFFGV-CWB2VKG-SL3ALAP";
          hostname = "phi";
        }
        {
          name = "sigma";
          id =
            "MYUB4WO-KFBERW6-VC3VXYY-K32WL7S-CX7X5NP-5JZYCEE-NNLYRT5-UXWP6AP";
        }
        {
          name = "pixel-6a";
          id =
            "NURXDKI-MPMVCY3-24YQHHX-6PDTE47-YP6QVO3-PC47MAP-BJY6LO6-6HLJAAQ";
        }
      ]);

      folders = lib.mkMerge (map mkFolder [
        {
          id = "7y829-o47k9";
          name = "Signal Backup";
          devices = {
            phi-nixos = {
              path = "/data/Backup/Signal";
              type = "receiveonly";

              versioning = {
                type = "staggered";
                # Keep old versions for 14 days
                params.maxAge = toString (14 * 24 * 60 * 60);
              };
            };
            pixel-6a = { };
          };
        }
        {
          id = "2odnx-6qz1l";
          name = "Pictures.sigma";
          devices = {
            phi-nixos = {
              path = "/data/Pictures/Pictures.sigma";
              type = "receiveonly";
              versioning = {
                type = "trashcan";
                params.cleanoutDays = "14";
              };
            };
            sigma = {
              path = "/persist${
                  config.users.users.${user}.home
                }/Pictures/Pictures.sigma";
            };
          };
        }
        {
          id = "3fpud-18f7a";
          name = "Screenshots.sigma";
          devices = {
            phi-nixos = {
              path = "/data/Pictures/Screenshots.sigma";
              type = "receiveonly";
              versioning = {
                type = "trashcan";
                params.cleanoutDays = "14";
              };
            };
            sigma = {
              path = "/persist${
                  config.users.users.${user}.home
                }/Pictures/Screenshots.sigma";
            };
          };
        }
        {
          id = "dd8lo-8p1o4";
          name = "Gramps";
          devices = {
            # Managed manually currently
            hermes-macos = { };
            hermes-nixos = {
              path = "${config.users.users.${user}.home}/.gramps";
            };
            phi-nixos = {
              path = "${config.users.users.${user}.home}/.gramps";
            };
            sigma = {
              path = "/persist${config.users.users.${user}.home}/.gramps";
            };
          };
          versioning = {
            type = "simple";
            # Only keep last 2 old versions
            params.keep = "2";
          };
        }
      ]);

      gui = {
        user = host;
        password = {
          hermes =
            "$2a$10$Ebr8QF6JgFbEyHNc2U6jjOj0WUAeqg0V1JKd1ymAIOuktUU0yr2A6";
          phi = "$2a$10$CTnvJaVO1L.dluML7fTYde2bh7E5rluYCtcW5rptoabXD1U8JZZsq";
          sigma =
            "$2a$10$wdfmhwbLNu9jSForuNG5pe2AAqL8d67G1TIa/Gk7DTO/SM6uuIZve";
          eris = "$2a$10$pDw1ciPdbkXp3fhTqYBJGeO9JEcrF2EMZXVAXrn1q3cenn64lJPsO";
          aether =
            "$2a$10$sjjfk8wLSdiNc2LiMaqBneQpJO.rjYCOoMxdmjWIgzKNkWUPnMPTC";
        }.${host};
      };
    };
  };
}
