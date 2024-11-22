{
  nixosModule = { user, ... }: {
    programs.adb.enable = true;

    users.users.${user}.extraGroups = [ "adbusers" ];
  };

  homeModule = { pkgs, ... }: {
    home.packages =
      builtins.attrValues { inherit (pkgs) android-tools scrcpy; };
  };
}
