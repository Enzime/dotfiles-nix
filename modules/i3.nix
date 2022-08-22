{
  imports = [ "graphical" "i3-sway" ];

  nixosModule = { pkgs, ... }: {
    services.xserver.displayManager.defaultSession = "none+i3";
    services.xserver.windowManager.i3.enable = true;

    # Allows storage devices to be controlled over D-Bus
    services.udisks2.enable = true;
    # Used as an abstraction over udisk2 by file managers
    services.gvfs.enable = true;

    services.gnome.gnome-keyring.enable = true;
    programs.seahorse.enable = true;

    # Some D-Bus errors were occuring on `switch` without this line
    programs.dconf.enable = true;
  };

  hmModule = { config, pkgs, lib, configRevision, ... }: {
    home.packages = builtins.attrValues {
      inherit (pkgs) xclip fira-mono font-awesome_5;
      inherit (pkgs.xfce) thunar;
    };

    xsession.windowManager.i3.enable = true;
    programs.feh.enable = true;
    services.redshift.enable = true;
    services.polybar.enable = true;
    services.screen-locker.enable = true;
    services.udiskie.enable = true;

    xsession.windowManager.i3.config = {
      startup = [
        { command = "systemctl --user restart polybar"; always = true; notification = false; }
        { command = "1password"; notification = false; }
      ];

      floating.criteria = [ { "instance" = "^floating$"; } ];

      keybindings = let
        mod = "Mod1";
        screenshotFilename = "${config.xdg.userDirs.pictures}/Screenshots/$(date +%y-%m-%d_%H-%M-%S).png";
        i3-ws = "${pkgs.i3-ws}/bin/i3-ws";
        maim = "${pkgs.maim}/bin/maim";
        xdotool = "${pkgs.xdotool}/bin/xdotool";
      in {
        "Control+Shift+2" = "exec bash -c '${maim} -i $(${xdotool} getactivewindow) ${screenshotFilename}'";
        "Control+Shift+3" = "exec bash -c '${maim} ${screenshotFilename}'";
        "Control+Shift+4" = "exec bash -c '${maim} -s ${screenshotFilename}'";

        # `xkill` will fail to grab the cursor if executed on button press
        # WORKAROUND: https://www.reddit.com/r/i3wm/wiki/faq/screenshot_binding
        "Control+Mod4+${mod}+q" = "--release exec ${pkgs.xorg.xkill}/bin/xkill";

        # When pressing the keybinding too fast, `i3lock` will turn the screen back on
        "Mod4+l" = "--release exec ${pkgs.xorg.xset}/bin/xset dpms force off";

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

        scroll-up = "#i3.prev";
        scroll-down = "#i3.next";
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
