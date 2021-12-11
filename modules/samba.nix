{
  nixosModule = { ... }: {
    services.samba.enable = true;
    services.samba.openFirewall = true;
    services.samba.shares.phi = {
      path = "/";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = "enzime";
      "force group" = "users";
    };
  };
}
