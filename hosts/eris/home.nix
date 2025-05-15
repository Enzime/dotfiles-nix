{
  wayland.windowManager.sway.config.workspaceOutputAssign = [
    {
      workspace = "1";
      output = "HEADLESS-1";
    }
    {
      workspace = "1";
      output = "VGA-1";
    }
  ];

  wayland.windowManager.sway.config.startup =
    [ { command = "firefox"; } { command = "deluge"; } ];
}
