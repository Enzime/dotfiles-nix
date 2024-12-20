{
  nixosModule = { user, ... }: {
    services.samba.enable = true;
    services.samba.settings.everything = {
      path = "/";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = user;
      "force group" = "users";
    };
  };
}
