{
  nixosModule = { config, pkgs, lib, ... }: {
    age.secrets.duckdns.file = ../secrets/duckdns.age;

    systemd.services.duckdns = {
      description = "Update DuckDNS";
      serviceConfig = {
        EnvironmentFile = config.age.secrets.duckdns.path;
        ExecStart = "${
            lib.getExe pkgs.curl
          } 'https://www.duckdns.org/update?domains=\${SUBDOMAIN}&token=\${TOKEN}&ip='";
      };
    };

    systemd.timers.duckdns = {
      description = "Update DuckDNS every hour";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnActiveSec = "5m";
        OnUnitActiveSec = "1h";
      };
    };
  };
}
