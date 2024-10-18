{
  nixosModule = { user, ... }: {
    programs.adb.enable = true;

    users.users.${user}.extraGroups = [ "adbusers" ];
  };
}
