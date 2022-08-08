{
  imports = [ "graphical" "i3-sway" ];

  nixosModule = { ... }: {
    programs.sway.enable = true;

    xdg.portal.wlr.enable = true;
  };

  hmModule = { config, pkgs, ... }: {
    wayland.windowManager.sway.enable = true;
    wayland.windowManager.sway.package = null;
    programs.waybar.enable = true;

    wayland.windowManager.sway.config = {
      startup = [
        { command = "systemctl --user restart waybar"; always = true; }
        { command = "1password"; }
      ];

      floating.criteria = [ { "app_id" = "^floating$"; } ];

      keybindings = let
        mod = "Mod1";
        screenshotFilename = "${config.xdg.userDirs.pictures}/Screenshots/$(date +%y-%m-%d_%H-%M-%S).png";
        grim = "${pkgs.grim}/bin/grim";
        swaymsg = "${pkgs.sway}/bin/swaymsg";
        jq = "${pkgs.jq}/bin/jq";
        slurp = "${pkgs.slurp}/bin/slurp";
      in {
        "Control+Shift+2" = "exec ${pkgs.writeShellScript "grim-current-window" ''
          REGION=$(${swaymsg} -t get_tree | ${jq} -j '.. | select(.type?) | select(.focused).rect | "\(.x),\(.y) \(.width)x\(.height)"')
          ${grim} -g "$REGION" ${screenshotFilename}
        ''}";
        "Control+Shift+3" = "exec bash -c '${grim} ${screenshotFilename}'";
        "Control+Shift+4" = "exec ${pkgs.writeShellScript "grim-slurp" ''
          REGION=$(${swaymsg} -t get_tree | ${jq} -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | ${slurp})
          ${grim} -g "$REGION" ${screenshotFilename}
        ''}";

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

        "${mod}+Shift+r" = "reload";
      };
    };

    systemd.user.services.swayidle = {
      Unit = {
        Description = "Idle Manager for Wayland";
        Documentation = [ "man:swayidle(1)" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service.ExecStart = let
        swayidle = "${pkgs.swayidle}/bin/swayidle";
        swaymsg = "${pkgs.sway}/bin/swaymsg";
        swaylock = "${pkgs.swaylock}/bin/swaylock";
      in ''
        ${swayidle} -w -d \
          timeout 1 'exit 0' \
              resume '${swaymsg} "output * dpms on"' \
          timeout 300 'loginctl lock-session' \
              resume '${swaymsg} "output * dpms on"' \
          lock '${swaylock} -f -c 000000 && ${swaymsg} "output * dpms off"'
      '';

      Install.WantedBy = [ "sway-session.target" ];
    };

    programs.waybar.settings = [{
      layer = "top";
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "sway/window" ];
      modules-right = [ "battery" "clock" "tray" ];
      "sway/window" = {
        max-length = 50;
      };
      battery = {
        format = "{capacity}% {icon}";
        format-icons = [ "" "" "" "" "" ];
      };
      clock = {
        format = "{:%a %b %d %I:%M:%S %p}";
        interval = 1;
      };
    }];

    programs.waybar.systemd.enable = true;
    programs.waybar.systemd.target = "sway-session.target";
  };
}
