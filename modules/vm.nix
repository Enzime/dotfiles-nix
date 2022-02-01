{
  nixosModule = { config, lib, user, ... }: let
    inherit (lib) mkIf mkVMOverride;
  # The `virtualisation.diskImage` option only exists when using `nixos-rebuild build-vm`
  in mkIf (builtins.hasAttr "diskImage" config.virtualisation) {
    networking.interfaces = mkVMOverride { };

    users.users.root.password = "apple";
    users.users.${user}.password = "apple";
  };

  # WORKAROUND: { osConfig ? { }, ... }: fails when using `home-manager build`
  hmModule = { lib, ... }@args: let
    inherit (lib) hasAttrByPath mkIf mkVMOverride;
  in mkIf (hasAttrByPath [ "osConfig" "virtualisation" "diskImage" ] args) {
    home.file.".zshrc.secrets".text = builtins.trace "hi" "";

    services.polybar.config."bar/centre".monitor = mkVMOverride "Virtual-1";

    xsession.windowManager.i3.config.startup = mkVMOverride [
      { command = "systemctl --user restart polybar"; always = true; notification = false; }
    ];

    xsession.windowManager.i3.config.workspaceOutputAssign = mkVMOverride [
      { workspace = "101"; output = "Virtual-1"; }
    ];
  };
}
