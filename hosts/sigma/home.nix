{ ... }:

{
  xsession.windowManager.i3.config.workspaceOutputAssign = [
    { workspace = "101"; output = "eDP-1"; }
  ];

  wayland.windowManager.sway.config.output = {
    eDP-1 = {
      scale = "1.5";
    };
  };

  services.polybar.config = {
    "module/battery" = {
      battery = "BAT1";
      adapter = "ACAD";
    };
  };
}
