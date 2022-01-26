{ ... }:

{
  xsession.windowManager.i3.config.workspaceOutputAssign = [
    { workspace = "101"; output = "eDP-1"; }
  ];

  services.polybar.config = {
    "module/battery" = {
      battery = "BAT1";
      adapter = "ACAD";
    };
  };
}
