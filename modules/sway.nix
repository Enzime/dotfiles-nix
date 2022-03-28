{
  imports = [ "graphical" "i3-sway" ];

  nixosModule = { ... }: {
    programs.sway.enable = true;
  };

  hmModule = { pkgs, ... }: {
    wayland.windowManager.sway.enable = true;
    wayland.windowManager.sway.package = null;

    wayland.windowManager.sway.config = {
      keybindings = let
        mod = "Mod1";
      in {
        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";

        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";
        "${mod}+Shift+0" = "move container to workspace number 10";

        "Mod4+l" = "exec loginctl lock-session";
      };
    };

    systemd.user.services.swayidle = {
      Unit = {
        Description = "Idle Manager for Wayland";
        Documentation = [ "man:swayidle(1)" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service.ExecStart = ''
        ${pkgs.swayidle}/bin/swayidle -w -d \
          timeout 1 'exit 0' \
              resume 'swaymsg "output * dpms on"' \
          timeout 60 'loginctl lock-session' \
              resume 'swaymsg "output * dpms on"' \
          lock 'swaylock -f -c 000000 && swaymsg "output * dpms off"'
      '';

      Install.WantedBy = [ "sway-session.target" ];
    };
  };
}
