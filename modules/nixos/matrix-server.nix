{
  config,
  pkgs,
  ...
}:

let
  cfg = config.systemd.services.matrix-synapse.serviceConfig;
in
{
  services.matrix-synapse.settings.federation_domain_whitelist = [ ];

  services.mautrix-signal.enable = true;
  services.mautrix-signal.package = pkgs.mautrix-signal.override {
    withGoolm = true;
  };
  services.mautrix-signal.settings = {
    network.displayname_template = ''{{or .Nickname .ContactName .ProfileName .PhoneNumber "Unknown user"}} (Signal)'';

    bridge = {
      permissions = {
        "test.enzim.ee" = "user";
        "@enzime:test.enzim.ee" = "admin";
      };

      bridge_matrix_leave = false;
      mute_only_on_create = false;
      personal_filtering_spaces = false;
    };

    homeserver = {
      address = "http://localhost:8008";
    };

    logging.min_level = "debug";
  };

  preservation.preserveAt."/persist".directories = [
    {
      directory = "/var/lib/matrix-synapse";
      user = cfg.User;
      group = cfg.Group;
    }
    "/var/lib/mautrix-signal"
  ];
}
