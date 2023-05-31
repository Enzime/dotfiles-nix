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

  xsession.windowManager.i3.config.startup = [{
    command = "i3 workspace 101";
    notification = false;
  }];

  xsession.windowManager.i3.config.workspaceOutputAssign = [{
    workspace = "101";
    output = "DisplayPort-0";
  }];

  services.polybar = {
    config = { "bar/centre" = { monitor = "DisplayPort-0"; }; };
    script = mkForce ''
      polybar centre &
    '';
  };

  dconf.settings = {
    # `phi` never sleeps
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };
  };

  services.screen-locker.inactiveInterval = 1;
  services.screen-locker.xautolock.enable = mkForce true;
}
