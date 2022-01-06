{
  nixosModule = { pkgs, ... }: {
    age.secrets.duckdns.file = ../secrets/duckdns.age;

    systemd.services.duckdns = {
      description = "Update DuckDNS";
      serviceConfig = {
        EnvironmentFile = "/run/agenix/duckdns";
        ExecStart = "${pkgs.curl}/bin/curl 'https://www.duckdns.org/update?domains=\${SUBDOMAIN}&token=\${TOKEN}&ip='";
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
