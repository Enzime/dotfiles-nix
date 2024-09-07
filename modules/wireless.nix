{
  nixosModule = { config, pkgs, lib, ... }: {
    networking.networkmanager.enable = true;
    networking.networkmanager.plugins =
      assert !config.networking.networkmanager ? enableDefaultPlugins;
      lib.mkForce [ ];
    networking.useDHCP = lib.mkForce false;

    age.secrets.wireless.file = ../secrets/wireless.age;

    networking.networkmanager.ensureProfiles.environmentFiles =
      [ config.age.secrets.wireless.path ];

    networking.networkmanager.ensureProfiles.profiles = {
      network-1 = {
        connection = {
          id = "$NETWORK_1_SSID";
          type = "wifi";
        };

        wifi = {
          mode = "infrastructure";
          ssid = "$NETWORK_1_SSID";
        };

        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-psk";
          psk = "$NETWORK_1_KEY";
        };
      };

      network-2 = {
        connection = {
          id = "$NETWORK_2_SSID";
          type = "wifi";
        };

        wifi = {
          mode = "infrastructure";
          ssid = "$NETWORK_2_SSID";
        };

        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-psk";
          psk = "$NETWORK_2_KEY";
        };
      };
    };

    # WORKAROUND: https://github.com/NixOS/nixpkgs/issues/296953
    systemd.services.NetworkManager-wait-online = {
      serviceConfig = {
        # These each get converted into separate directives and the empty directive is
        # necessary to override the original service's ExecStart
        ExecStart = [ "" "${lib.getExe' pkgs.networkmanager "nm-online"} -q" ];
      };
    };
  };
}
