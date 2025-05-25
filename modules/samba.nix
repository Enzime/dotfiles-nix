{
  nixosModule = { user, hostname, ... }: {
    services.samba.enable = true;
    # Set password for user with `sudo smbpasswd -a <user>`
    services.samba.settings.${hostname} = {
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
