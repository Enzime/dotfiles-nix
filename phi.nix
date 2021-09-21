{ lib, pkgs, ... }:

let
    inherit (lib) mkDefault;
in {
  # Disable tab bar when using vertical tabs
  home.file.".mozilla/firefox/userChrome.css".text = ''
    #TabsToolbar { visibility: collapse !important; }
  '';

  xsession.windowManager.i3 = mkDefault {
    extraConfig = ''
      workspace 101 output DisplayPort-1
      workspace 201 output DisplayPort-0
      workspace 301 output DisplayPort-2
      
      exec --no-startup-id i3 workspace 101
      exec --no-startup-id i3 workspace 201
      exec --no-startup-id i3 workspace 301

      # lightdm is set up to autologin, so we still want the user to login
      exec --no-startup-id i3lock
    '';
  };

  services.polybar = mkDefault {
    config = {
      "bar/base" = {
        # TODO: just prepend `nixpkgs` to `modules-right`
        modules-right = "nixpkgs wireless ethernet fs memory date";
      };

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

      "module/nixpkgs" = let 
        latest-nixpkgs = (pkgs.writeScript "latest-nixpkgs" ''
          #!${pkgs.stdenv.shell}
          # get latest commit hash for channel
          LATEST=$(${pkgs.curl}/bin/curl -s https://channels.nix.gsc.io/nixos-unstable/history | ${pkgs.coreutils}/bin/tail -n 1 | ${pkgs.coreutils}/bin/cut -d ' ' -f 1)
          # get commit hash of currently running system
          RUNNING=$(${pkgs.coreutils}/bin/cat /run/current-system/nixos-version | ${pkgs.coreutils}/bin/cut -d '.' -f 4)
          export GIT_DIR=~/nixpkgs/.git
          UPDATE_FOUND=false
          # check if running commit exists in ~/nixpkgs
          if ${pkgs.git}/bin/git cat-file -e $RUNNING^{commit} 2>/dev/null; then
            if ! ${pkgs.git}/bin/git merge-base --is-ancestor $LATEST $RUNNING 2>/dev/null; then
              UPDATE_FOUND=true
            fi
          else
            # if running commit doesn't exist in ~/nixpkgs, it has to have come from a channel
            # this means if $LATEST != $RUNNING, $LATEST must be newer
            if [[ $(echo $LATEST | ${pkgs.coreutils}/bin/cut -c -7) != $(echo $RUNNING | ${pkgs.coreutils}/bin/cut -c -7) ]]; then
              UPDATE_FOUND=true
            fi
          fi
          if [[ $UPDATE_FOUND == "true" ]]; then
            echo  $(echo $LATEST | ${pkgs.coreutils}/bin/cut -c -7)
          else
            echo  $(echo $RUNNING | ${pkgs.coreutils}/bin/cut -c -7)
          fi
        '');
      in {
        type = "custom/script";
        exec = "${latest-nixpkgs}";
        interval = 300;
      };
    };
    script = ''
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
