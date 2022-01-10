{
  # The `virtualisation.diskImage` option only exists when using `nixos-rebuild build-vm`
  nixosModule = { config, user, lib, ... }: lib.mkIf (builtins.hasAttr "diskImage" config.virtualisation) {
    users.users.root.password = "apple";
    users.users.${user}.password = "apple";
  };
}
