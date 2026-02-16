{
  nixosModule =
    { user, pkgs, ... }:
    {
      environment.systemPackages = builtins.attrValues {
        inherit (pkgs) android-tools;
      };

      users.users.${user}.extraGroups = [ "adbusers" ];
    };

  homeModule =
    { pkgs, ... }:
    {
      home.packages = builtins.attrValues { inherit (pkgs) android-tools scrcpy; };
    };
}
