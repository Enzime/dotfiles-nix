{
  nixosModule = { config, lib, user, ... }: let
    inherit (lib) mkIf mkVMOverride;

    hmModule = { ... }: {
      home.file.".zshrc.secrets".text = "";

      services.polybar.config."bar/centre".monitor = mkVMOverride "Virtual-1";

      xsession.windowManager.i3.config.startup = mkVMOverride [
        { command = "systemctl --user restart polybar"; always = true; notification = false; }
      ];

      xsession.windowManager.i3.config.workspaceOutputAssign = mkVMOverride [
        { workspace = "101"; output = "Virtual-1"; }
      ];
    };
  # The `virtualisation.diskImage` option only exists when using `nixos-rebuild build-vm`
  in mkIf (builtins.hasAttr "diskImage" config.virtualisation) {
    # We can't use a normal `hmModule` as we won't be able to make it conditional
    home-manager.users.${user}.imports = [ hmModule ];

    users.users.root.password = "apple";
    users.users.${user}.password = "apple";

    networking.interfaces = mkVMOverride { };
  };
}
