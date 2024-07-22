{ lib, ... }:

let inherit (lib) mkForce;
in {
  xsession.windowManager.i3.config.workspaceOutputAssign = [{
    workspace = "101";
    output = "VNC-0";
  }];

  xsession.windowManager.i3.config.startup = [
    {
      command = "firefox";
      notification = false;
    }
    {
      command = "deluge";
      notification = false;
    }
  ];

  services.polybar = {
    config = {
      "bar/base" = {
        modules-right = mkForce "dotfiles ethernet fs memory date";
      };

      "bar/centre" = { monitor = "VNC-0"; };
    };
  };
}
