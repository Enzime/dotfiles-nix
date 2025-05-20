{
  wayland.windowManager.sway.config.output = { eDP-1 = { scale = "1.5"; }; };

  wayland.windowManager.sway.config.workspaceOutputAssign = [{
    workspace = "1";
    output = "eDP-1";
  }];

  xdg.userDirs.download = "$HOME/Downloads";
  xdg.userDirs.pictures = "$HOME/Pictures";

  preservation.directories = [ "Code" "Downloads" "Pictures" "Work" ];
}
