{
  darwinModule = { user, hostname, pkgs, ... }: {
    environment.systemPackages =
      builtins.attrValues { inherit (pkgs) syncthing-macos; };

    launchd.user.agents.syncthing = {
      command =
        ''"/Applications/Nix Apps/Syncthing.app/Contents/MacOS/Syncthing"'';
      serviceConfig.RunAtLoad = true;
    };

    system.defaults.CustomUserPreferences."com.github.xor-gate.syncthing-macosx" =
      {
        SUEnableAutomaticChecks = false;
        SUSendProfileInfo = 0;
        StartAtLogin = 0;
        URI = "http://${hostname}:8384";
      };

    # Don't let Syncthing for macOS hardcode the path for `syncthing`
    system.activationScripts.extraActivation.text = ''
      if sudo -u ${user} defaults read com.github.xor-gate.syncthing-macosx Executable &>/dev/null; then
        sudo -u ${user} defaults delete com.github.xor-gate.syncthing-macosx Executable
      fi
    '';
  };

  nixosModule = { config, user, host, hostname, lib, ... }: {
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
          name = "hyperion-macos";
          id =
            "OEAWYP7-XUL5L4A-WH4PM4P-UNTIIXC-3C2LWFY-F2WPKNY-H4TFMWI-IFZSCQU";
        }
        {
          name = "phi-nixos";
          id =
            "2YEN2S7-JYISWE4-UGUF6N4-7ZNSDNX-IKLEDGT-4WLFFGV-CWB2VKG-SL3ALAP";
        }
        {
          name = "sigma";
          id =
            "MYUB4WO-KFBERW6-VC3VXYY-K32WL7S-CX7X5NP-5JZYCEE-NNLYRT5-UXWP6AP";
        }
        {
          name = "eris";
          id =
            "OSL7C3U-VQS2KVT-WRK3WTK-4XDJR2D-AGDAL3Q-PA2YPVB-QQ72LAR-EDBZPQL";
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
          id = "a2j2q-rjjju";
          name = "Screenshots.hyperion";
          devices = {
            # Managed manually currently
            hyperion-macos = {
              path = "${config.users.users.${user}.home}/Pictures/Screenshots";
            };
            phi-nixos = {
              path = "/data/Pictures/Screenshots.hyperion";
              type = "receiveonly";
              versioning = {
                type = "trashcan";
                params.cleanoutDays = "14";
              };
            };
          };
        }
        {
          id = "dd8lo-8p1o4";
          name = "Gramps";
          devices = {
            # Managed manually currently
            hyperion-macos = {
              path = "${config.users.users.${user}.home}/.local/share/gramps";
            };
            phi-nixos = {
              path = "${config.users.users.${user}.home}/.local/share/gramps";
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
          phi = "$2a$10$CTnvJaVO1L.dluML7fTYde2bh7E5rluYCtcW5rptoabXD1U8JZZsq";
          sigma =
            "$2a$10$wdfmhwbLNu9jSForuNG5pe2AAqL8d67G1TIa/Gk7DTO/SM6uuIZve";
          eris = "$2a$10$pDw1ciPdbkXp3fhTqYBJGeO9JEcrF2EMZXVAXrn1q3cenn64lJPsO";
        }.${host};
      };
    };
  };
}
