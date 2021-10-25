{
  nixosModule = { ... }: {
    services.xserver.windowManager.i3.enable = true;
  };

  hmModule = { pkgs, configRevision, ... }: {
    home.packages = builtins.attrValues {
      inherit (pkgs) fira-mono font-awesome;
    };

    xsession.windowManager.i3.enable = true;
    programs.termite.enable = true;
    programs.feh.enable = true;
    services.redshift.enable = true;
    services.polybar.enable = true;
    services.screen-locker.enable = true;

    xsession.windowManager.i3.config = {
      bars = [ ];
      startup = [
        { command = "systemctl --user restart polybar"; always = true; notification = false; }
        { command = "signal-desktop"; }
      ];

      window = {
        titlebar = false;
        border = 1;
      };

      floating.criteria = [ { "instance" = "^floating$"; } ];

      colors = {
        focused         = { border = "#4c7899"; background = "#e61f00"; text = "#ffffff"; indicator = "#00ccff"; childBorder = "#e61f00"; };
        focusedInactive = { border = "#333333"; background = "#0a0a0a"; text = "#ffffff"; indicator = "#484e50"; childBorder = "#0a0a0a"; };
        unfocused       = { border = "#333333"; background = "#0d0c0c"; text = "#888888"; indicator = "#292d2e"; childBorder = "#0d0c0c"; };
      };

      keybindings = let
        mod = "Mod1";
        screenshotFilename = "/data/Pictures/Screenshots/$(date +%y-%m-%d_%H-%M-%S).png";
        # i3-ws fails to build with sandboxing enabled on non-NixOS OSes
        # WORKAROUND: sudo nix build nixpkgs.i3-ws --option sandbox false
        i3-ws = "${pkgs.i3-ws}/bin/i3-ws";
        maim = "${pkgs.maim}/bin/maim";
        xdotool = "${pkgs.xdotool}/bin/xdotool";
      in {
        "${mod}+Return" = "exec ${pkgs.termite}/bin/termite";
        "${mod}+Shift+Return" = "exec ${pkgs.termite}/bin/termite --name floating";

        "Mod4+l" = "exec loginctl lock-session";
        "Mod4+e" = "exec ${pkgs.shutdown-menu} -p rofi -c";

        "Control+Shift+2" = "exec bash -c '${maim} -i $(${xdotool} getactivewindow) ${screenshotFilename}'";
        "Control+Shift+3" = "exec bash -c '${maim} ${screenshotFilename}'";
        "Control+Shift+4" = "exec bash -c '${maim} -s ${screenshotFilename}'";

        "${mod}+Shift+q" = "kill";
        # `xkill` will fail to grab the cursor if executed on button press
        # WORKAROUND: https://www.reddit.com/r/i3wm/wiki/faq/screenshot_binding
        "Control+Mod4+${mod}+q" = "--release exec ${pkgs.xorg.xkill}/bin/xkill";
        "${mod}+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";

        "Control+${mod}+Left" = "focus output left";
        "Control+${mod}+Right" = "focus output right";

        "${mod}+Left" = "focus left";
        "${mod}+Down" = "focus down";
        "${mod}+Up" = "focus up";
        "${mod}+Right" = "focus right";

        "Control+${mod}+h" = "focus output left";
        "Control+${mod}+l" = "focus output right";

        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";

        "Control+${mod}+Shift+Left" = "move container to output left; focus output left";
        "Control+${mod}+Shift+Right" = "move container to output right; focus output right";

        "${mod}+Shift+Left" = "move left";
        "${mod}+Shift+Down" = "move down";
        "${mod}+Shift+Up" = "move up";
        "${mod}+Shift+Right" = "move right";

        "Control+${mod}+Shift+h" = "move container to output left; focus output left";
        "Control+${mod}+Shift+l" = "move container to output right; focus output right";

        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        "${mod}+Shift+v" = "split h";
        "${mod}+v" = "split v";
        "${mod}+f" = "fullscreen toggle";

        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";

        "${mod}+Shift+space" = "floating toggle";
        "${mod}+space" = "focus mode_toggle";

        "${mod}+a" = "focus parent";

        # switch between workspaces on the current monitor
        "${mod}+1" = "exec ${i3-ws} --ws 1";
        "${mod}+2" = "exec ${i3-ws} --ws 2";
        "${mod}+3" = "exec ${i3-ws} --ws 3";
        "${mod}+4" = "exec ${i3-ws} --ws 4";
        "${mod}+5" = "exec ${i3-ws} --ws 5";
        "${mod}+6" = "exec ${i3-ws} --ws 6";
        "${mod}+7" = "exec ${i3-ws} --ws 7";
        "${mod}+8" = "exec ${i3-ws} --ws 8";
        "${mod}+9" = "exec ${i3-ws} --ws 9";
        "${mod}+0" = "exec ${i3-ws} --ws 10";

        "${mod}+Shift+1" = "exec ${i3-ws} --ws --shift 1";
        "${mod}+Shift+2" = "exec ${i3-ws} --ws --shift 2";
        "${mod}+Shift+3" = "exec ${i3-ws} --ws --shift 3";
        "${mod}+Shift+4" = "exec ${i3-ws} --ws --shift 4";
        "${mod}+Shift+5" = "exec ${i3-ws} --ws --shift 5";
        "${mod}+Shift+6" = "exec ${i3-ws} --ws --shift 6";
        "${mod}+Shift+7" = "exec ${i3-ws} --ws --shift 7";
        "${mod}+Shift+8" = "exec ${i3-ws} --ws --shift 8";
        "${mod}+Shift+9" = "exec ${i3-ws} --ws --shift 9";
        "${mod}+Shift+0" = "exec ${i3-ws} --ws --shift 10";

        # switch monitors
        "Control+${mod}+1" = "exec ${i3-ws} 1";
        "Control+${mod}+2" = "exec ${i3-ws} 2";
        "Control+${mod}+3" = "exec ${i3-ws} 3";
        "Control+${mod}+4" = "exec ${i3-ws} 4";
        "Control+${mod}+5" = "exec ${i3-ws} 5";
        "Control+${mod}+6" = "exec ${i3-ws} 6";
        "Control+${mod}+7" = "exec ${i3-ws} 7";
        "Control+${mod}+8" = "exec ${i3-ws} 8";
        "Control+${mod}+9" = "exec ${i3-ws} 9";
        "Control+${mod}+0" = "exec ${i3-ws} 10";

        "Control+${mod}+Shift+1" = "exec ${i3-ws} --shift 1";
        "Control+${mod}+Shift+2" = "exec ${i3-ws} --shift 2";
        "Control+${mod}+Shift+3" = "exec ${i3-ws} --shift 3";
        "Control+${mod}+Shift+4" = "exec ${i3-ws} --shift 4";
        "Control+${mod}+Shift+5" = "exec ${i3-ws} --shift 5";
        "Control+${mod}+Shift+6" = "exec ${i3-ws} --shift 6";
        "Control+${mod}+Shift+7" = "exec ${i3-ws} --shift 7";
        "Control+${mod}+Shift+8" = "exec ${i3-ws} --shift 8";
        "Control+${mod}+Shift+9" = "exec ${i3-ws} --shift 9";
        "Control+${mod}+Shift+0" = "exec ${i3-ws} --shift 10";

        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+r" = "restart";

        "${mod}+o" = "mode osu";
        "${mod}+r" = "mode resize";
      };

      modes = {
        osu = { End = "mode default"; };
        resize = {
          h = "resize shrink width 2 px or 2 ppt";
          j = "resize grow height 2 px or 2 ppt";
          k = "resize shrink height 2 px or 2 ppt";
          l = "resize grow width 2 px or 2 ppt";

          Left = "resize shrink width 2 px or 2 ppt";
          Down = "resize grow height 2 px or 2 ppt";
          Up = "resize shrink height 2 px or 2 ppt";
          Right = "resize grow width 2 px or 2 ppt";

          "Shift+h" = "resize shrink width 20 px or 20 ppt";
          "Shift+j" = "resize grow height 20 px or 20 ppt";
          "Shift+k" = "resize shrink height 20 px or 20 ppt";
          "Shift+l" = "resize grow width 20 px or 20 ppt";

          "Shift+Left" = "resize shrink width 20 px or 20 ppt";
          "Shift+Down" = "resize grow height 20 px or 20 ppt";
          "Shift+Up" = "resize shrink height 20 px or 20 ppt";
          "Shift+Right" = "resize grow width 20 px or 20 ppt";

          Escape = "mode default";
        };
      };
    };

    services.polybar.package = pkgs.polybar.override { i3Support = true; };
    services.polybar.script = ''
      polybar centre &
    '';
    services.polybar.config = {
      "bar/base" = {
        width = "100%";
        height = 27;
        background = "#0d0c0c";
        foreground = "#fff5ed";

        font-0 = "Fira Mono:pixelsize=10;1";
        font-1 = "Font Awesome 5 Free:style=Solid:pixelsize=10;1";

        modules-left = "i3";
        modules-right = "dotfiles wireless ethernet fs memory date";

        module-margin-left = 2;
        module-margin-right = 2;

        scroll-up = "i3wm-wsprev";
        scroll-down = "i3wm-wsnext";
      };

      "bar/centre" = {
        "inherit" = "bar/base";
        tray-position = "right";
      };

      "module/i3" = {
        type = "internal/i3";
        pin-workspaces = true;
        wrapping-scroll = false;
        label-mode-padding = 2;
        label-mode-foreground = "#000000";
        label-mode-background = "#ffb52a";
        label-focused = "%index%";
        label-focused-background = "#fff";
        label-focused-foreground = "#000";
        label-focused-padding = 2;

        label-unfocused = "%index%";
        label-unfocused-padding = 2;

        label-visible = "%index%";
        label-visible-background = "#292929";
        label-visible-padding = 2;

        label-urgent = "%index%";
        label-urgent-background = "#ff3f3d";
        label-urgent-padding = 2;
      };

      "module/memory" = {
        type = "internal/memory";
        label = "RAM %percentage_used%% F%gb_free%";
      };

      "module/date" = {
        type = "internal/date";
        date = "%a %b %d";
        time = "%I:%M:%S %p";
        label = "%date% %time%";
        format-background = "#292929";
        format-padding = 3;
      };

      "module/fs" = {
        type = "internal/fs";
        interval = 1;
        mount-0 = "/";
        label-mounted = "%mountpoint% %percentage_used%% F%free%";
      };

      "module/ethernet" = {
        type = "internal/network";
        interface = "enp34s0";
        label-connected = "E:%downspeed% %upspeed%";
        label-disconnected = "E: Disconnected";
      };

      "module/wireless" = {
        type = "internal/network";
        interface = "wlo1";
      };

      "module/dotfiles" = {
        type = "custom/script";
        exec = "${pkgs.writeShellScript "latest-dotfiles" ''
          # necessary for `nixos-version` to find `cat`...
          export PATH=${pkgs.coreutils}/bin:$PATH

          # get latest commit hash for dotfiles
          LATEST=$(${pkgs.curl}/bin/curl -s https://github.com/Enzime/dotfiles-nix/commit/HEAD.patch | ${pkgs.coreutils}/bin/head -n 1 | ${pkgs.coreutils}/bin/cut -d ' ' -f 2)

          # get commit hash of currently running dotfiles
          RUNNING=${configRevision.full}

          UPDATE_FOUND=false

          if [[ $RUNNING == "dirty-inputs" ]]; then
            echo  $RUNNING
            exit
          fi

          export GIT_DIR=~/.config/nixpkgs/.git
          if ! ${pkgs.git}/bin/git merge-base --is-ancestor $LATEST ''${RUNNING%-dirty} 2>/dev/null; then
            UPDATE_FOUND=true
          fi

          if [[ $UPDATE_FOUND == "true" ]]; then
            echo  $(echo $LATEST | cut -c -7)
          else
            echo  ${configRevision.short}
          fi
        ''}";
        interval = 300;
      };
    };

    programs.termite.font = "DejaVu Sans Mono 10";
    programs.termite.scrollbackLines = -1;
    programs.termite.colorsExtra = ''
      # special
      foreground      = #fff5ed
      foreground_bold = #fff5ed
      cursor          = #00ccff
      background      = #0d0c0c

      # black
      color0  = #0a0a0a
      color8  = #73645d

      # red
      color1  = #e61f00
      color9  = #ff3f3d

      # green
      color2  = #6dd200
      color10 = #c1ff05

      # yellow
      color3  = #fa6800
      color11 = #ffa726

      # blue
      color4  = #255ae4
      color12 = #00ccff

      # magenta
      color5  = #ff0084
      color13 = #ff65a0

      # cyan
      color6  = #36fcd3
      color14 = #96ffe3

      # white
      color7  = #b6afab
      color15 = #fff5ed
    '';

    programs.feh = {
      buttons = {
        zoom_in = 4;
        zoom_out = 5;
      };

      keybindings = {
        save_image = null;
        delete = null;
      };
    };

    services.redshift = {
      temperature = {
        day = 5700;
        night = 3500;
      };
      latitude = "-38.0";
      longitude = "145.2";
    };

    services.screen-locker.lockCmd = "${pkgs.i3lock}/bin/i3lock -n -c 000000";
    services.screen-locker.xautolock.enable = false;

    systemd.user.services.pantheon-polkit-agent = {
      Unit = {
        Description = "Pantheon Polkit Agent";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };

      Service = {
        ExecStart =
          "${pkgs.pantheon.pantheon-agent-polkit}/libexec/policykit-1-pantheon/io.elementary.desktop.agent-polkit";
      };
    };
  };
}
