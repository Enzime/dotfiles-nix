{ lib, pkgs, ... }:

let
    inherit (lib) mkForce;
in {
  # Disable tab bar when using vertical tabs
  home.file.".mozilla/firefox/userChrome.css".text = ''
    #TabsToolbar { visibility: collapse !important; }
  '';

  xsession.windowManager.i3.extraConfig = ''
    workspace 101 output DisplayPort-1
    workspace 201 output DisplayPort-0
    workspace 301 output DisplayPort-2

    exec --no-startup-id i3 workspace 101
    exec --no-startup-id i3 workspace 201
    exec --no-startup-id i3 workspace 301

    # lightdm is set up to autologin, so we still want the user to login
    exec --no-startup-id i3lock
  '';

  services.polybar = {
    config = {
      "bar/left" = {
        "inherit" = "bar/base";
        monitor = "DisplayPort-1";
      };

      "bar/centre" = {
        monitor = "DisplayPort-0";
      };

      "bar/right" = {
        "inherit" = "bar/base";
        monitor = "DisplayPort-2";
      };
    };
    script = mkForce ''
      polybar left &
      polybar centre &
      polybar right &
    '';
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita";
    };
    gtk3.extraCss = "decoration {box-shadow: none; margin: 0;}";
  };
}
