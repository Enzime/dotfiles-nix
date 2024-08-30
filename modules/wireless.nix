{
  nixosModule = { config, lib, ... }: {
    networking.networkmanager.enable = true;
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
  };
}
