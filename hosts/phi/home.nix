{ lib, ... }:

let inherit (lib) mkForce;
in {
  wayland.windowManager.sway.config.output = {
    DP-1 = {
      mode = "3440x1440@144Hz";
      adaptive_sync = "on";
    };
  };

  wayland.windowManager.sway.config.workspaceOutputAssign = [{
    workspace = "1";
    output = "DP-1";
  }];
}
