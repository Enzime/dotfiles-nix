{
  nixosModule = { config, ... }: {
    services.samba.enable = true;
    services.samba.shares.phi = {
      path = "/";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = "enzime";
      "force group" = "users";
    };

    networking.firewall.allowedTCPPorts = (assert (!builtins.hasAttr "openFirewall" config.services.samba); [ 139 445 ]);
    networking.firewall.allowedUDPPorts = (assert (!builtins.hasAttr "openFirewall" config.services.samba); [ 137 138 ]);
  };
}
