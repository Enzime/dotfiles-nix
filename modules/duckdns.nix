{
  nixosModule = { pkgs, ... }: {
    systemd.services.duckdns = {
      description = "Update DuckDNS";
      serviceConfig = {
        ExecStart = "${pkgs.curl}/bin/curl 'https://www.duckdns.org/update?domains=enzime&token=d725755a-58af-4ca0-a28a-56a844640289&ip='";
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
