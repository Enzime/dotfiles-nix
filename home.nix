{ pkgs, lib, specialArgs ? {
  # Fallback to `/using/` files for non-flake systems
  hostname = (lib.removeSuffix "\n" (lib.readFile ./using/hostname));
  using = {
    i3 = builtins.pathExists ./using/i3;
    gnome = builtins.pathExists ./using/gnome;
    hidpi = builtins.pathExists ./using/hidpi;
  };
}, ... }:

let
  inherit (lib) assertMsg attrByPath hasAttrByPath mkIf mkMerge readFile;
  inherit (specialArgs) hostname;

  using = { i3 = false; gnome = false; hidpi = false; } // specialArgs.using;
in mkMerge [{
  # Replace `with pkgs;` with `inherit (pkgs)`
  # https://nix.dev/anti-patterns/language#with-attrset-expression
  home.packages = builtins.attrValues {
    inherit (pkgs) htop ranger peco;
  };

  home.extraBuilderCommands = "ln -sv ${./.} $out/dotfiles";

  home.sessionVariables = mkMerge [
    {
      EDITOR = "vim";
      VISUAL = "vim";
    }
    (mkIf using.hidpi {
      GDK_SCALE                    = 2;
      GDK_DPI_SCALE                = 0.5;
      QT_AUTO_SCREEN_SCALE_FACTOR  = 1;
      QT_FONT_DPI                  = 96;
    })
  ];

  xresources.properties = mkIf using.hidpi {
    "*dpi" = 192;
    "Xcursor.size" = 48;
  };

  home.file.".wgetrc".text = ''
    content_disposition=on
    continue=on
    no_parent=on
    robots=off
  '';

  xdg.userDirs = {
    enable = true;
    desktop = "\$HOME";
    documents = "\$HOME";
    download = "/data/Downloads";
    music = "\$HOME";
    pictures = "/data/Pictures";
    publicShare = "\$HOME";
    templates = "\$HOME";
    videos = "\$HOME";
  };

  programs.git = {
    enable = true;
    userName = "Michael Hoang";
    userEmail = "enzime@users.noreply.github.com";

    delta.enable = true;

    extraConfig = {
      advice = {
        addIgnoredFile = false;
      };
      core = {
        excludesFile = "${pkgs.writeText "global_ignore" ''
          /start.sh
        ''}";
        hooksPath = "~/.config/git/hooks";
      };
      init = {
        defaultBranch = "main";
      };
      fetch = {
        prune = true;
      };
      pull = {
        ff = "only";
      };
      url = {
        "https://github.com/" = { insteadOf = [ "gh:" "ghro:" ]; };
        "ssh://git@github.com/" = { insteadOf = "ghp:"; pushInsteadOf = "gh:"; };
        "___PUSH_DISABLED___" = { pushInsteadOf = "ghro:"; };
      };
    };
  };

  xdg.configFile."git/hooks/pre-commit" = {
    executable = true;
    text = ''
      #!/bin/sh
      git --no-pager diff --binary --no-color --cached | grep -i '^\+.*todo'

      no_todos_found=$?

      if [ $no_todos_found -eq 1 ]; then
        exit 0
      elif [ $no_todos_found -eq 0 ]; then
        echo "error: preventing commit whilst TODO in staged changes"
        echo "hint: Remove the TODO from staged changes before"
        echo "hint: commiting again."
        echo "hint: Use --no-verify (-n) to bypass this pre-commit hook."
        exit 1
      else
        echo "error: unknown error code returned by grep '$?'"
        exit 1
      fi
    '';
  };

  programs.zsh = {
    enable = true;

    initExtraFirst = ''
      path=(
        ~/.nix-profile/bin
        $path
      )
    '';

    prezto = {
      enable = true;

      pmodules = [
        "environment"
        "terminal"
        "editor"
        "history"
        "directory"
        "spectrum"
        "utility"
        # `git` just needs to be before `completion`
        "git"
        "completion"
        "prompt"
      ];
    };

    history = {
      extended = true;
      save = 1000000;
      size = 1000000;

      ignoreSpace = true;

      ignoreDups = true;
      expireDuplicatesFirst = true;
    };

    initExtra = ''
      function ga {
        if [[ -z $1 ]]; then
          git add -p
        else
          git add $@
        fi
      }

      function gbfm {
        if [[ ! -z $3 ]]; then
          start=$3
        elif [[ $(git rev-parse --abbrev-ref HEAD) == "HEAD" ]]; then
          start=HEAD
        elif git remote get-url upstream >/dev/null 2>&1; then
          start=upstream
        elif git remote get-url origin >/dev/null 2>&1; then
          start=origin
        else
          echo "Unknown start point"
          return 1
        fi

        git switch --no-track $1 $2 $start
      }

      function gfc {
        git clone $@ || return 1
        cd ./*(/om[1]) || return 1
        default_branch=$(git branch --show-current)
        git checkout origin || return 1
        git branch --delete $default_branch || return 1
      }

      function gps {
        branch=$(git rev-parse --abbrev-ref HEAD) || return 1

        if git remote get-url fork >/dev/null 2>&1; then
          remote=fork
        elif git remote get-url origin >/dev/null 2>&1; then
          remote=origin
        elif [[ -z $1 ]]; then
          remote=$1
        else
          echo "No remote specified"
          return 1
        fi

        if [[ $branch != "HEAD" ]]; then
          git push --set-upstream $remote $branch
        else
          echo "Not on a branch"
          return 1
        fi
      }

      function gt {
        git --no-pager diff --binary --no-color | grep -i '^\+.*todo'
      }

      function gts {
        git --no-pager diff --binary --no-color --cached | grep -i '^\+.*todo'
      }

      function gtu {
        git --no-pager diff --binary --no-color ''${1:-origin/master}...''${2:-HEAD} | grep -i '^\+.*todo'
      }

      # https://github.com/nix-community/nix-direnv#shell-integration
      nixify() {
        if [ ! -e ./.envrc ]; then
          echo "use nix" > .envrc
          direnv allow
        fi
        if [[ ! -e shell.nix ]]; then
          cat > shell.nix <<'EOF'
with import <nixpkgs> {};
mkShell {
  nativeBuildInputs = [
    bashInteractive
  ];
}
EOF
          ''${EDITOR:-vim} shell.nix
        fi
      }

      flakifiy() {
        if [ ! -e flake.nix ]; then
          nix flake new -t github:nix-community/nix-direnv .
        elif [ ! -e .envrc ]; then
          echo "use flake" > .envrc
          direnv allow
        fi
        ''${EDITOR:-vim} flake.nix
      }

      function ranger-cd {
        tempfile=$(mktemp)
        \ranger --choosedir="$tempfile" "''${@:-$(pwd)}" < $TTY
        test -f "$tempfile" &&
        if [[ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]]; then
            cd -- "$(cat "$tempfile")"
        fi
        rm -f -- "$tempfile"
      }

      function carry-ranger {
        \ranger < $TTY
        VISUAL=true zle edit-command-line
      }

      function carry-ranger-cd {
        ranger-cd
        VISUAL=true zle edit-command-line
      }

      function peco_select_history() {
        local peco
        [[ -z "$LBUFFER" ]] && peco="peco" || peco='peco --query "$LBUFFER"'
        BUFFER=$(fc -l -n 1 | tac | eval $peco)
        CURSOR=$#BUFFER         # move cursor
        zle -R -c               # refresh
      }

      zle -N peco_select_history
      bindkey '^R' peco_select_history
      bindkey -r '^S'

      autoload -z edit-command-line
      zle -N edit-command-line

      zle -N carry-ranger
      zle -N carry-ranger-cd

      bindkey '^E^E' edit-command-line
      bindkey '^Er' carry-ranger
      bindkey '^Ec' carry-ranger-cd
      bindkey -s ',R' 'source ~/.zshrc^M'

      if [ -z "$__ZSHRC_SOURCED" ]; then
        unalias gfc
      fi

      export __ZSHRC_SOURCED=1

      . ~/.zshrc.secrets
    '';

    shellAliases = {
      _ = "\\sudo ";
      sudo = "echo \"zsh: command not found: sudo\"";

      ls = "ls -F --color=auto";

      l = "ls -lah";
      ranger = "ranger-cd";

      gai = "git add --interactive";
      gaf = "git add --force";
      gbc = "gbfm -c";
      gbC = "gbfm -C";
      gbu = "git branch --set-upstream-to";
      gbv = "git branch -vv";
      gca = "git commit --amend";
      gco = "git checkout --patch";
      gcpa = "git cherry-pick --abort";
      gcpc = "git cherry-pick --continue";
      gC = "git checkout";
      gD = "git diff";
      gDs = "gD --cached";
      gf = "gfa --prune";
      gF = "git fetch";
      gln = "gl -n";
      gpx = "gp --delete";
      gRv = "gR -v";
      gs = "git status";
      gss = "git stash save -p";
      gsS = "git stash save --include-untracked";
      gS = "git show";
      gtx = "git tag --delete";
    };
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.neovim = {
    enable = true;
    vimAlias = true;
    # Adding `vim-plug` to `plugins` does not load it, just source it directly instead
    extraConfig = ''
      source ${pkgs.vimPlugins.vim-plug.rtp}/plug.vim
    '' + readFile ./files/init.vim;
  };

  programs.vscode = {
    enable = true;
    extensions = [
      pkgs.vscode-extensions.asvetliakov.vscode-neovim

      pkgs.vscode-extensions.eamodio.gitlens
      pkgs.vscode-extensions.shardulm94.trailing-spaces
      pkgs.vscode-extensions.dbaeumer.vscode-eslint
      # Currently broken on `nixpkgs-unstable`, disable until https://github.com/NixOS/nixpkgs/issues/137314 is fixed
      # pkgs.vscode-extensions.ms-python.python
      pkgs.vscode-extensions.ms-python.vscode-pylance
      pkgs.vscode-extensions.jnoortheen.nix-ide

      pkgs.vscode-extensions.kamikillerto.vscode-colorize
    ];
    keybindings = [
      { "key" = "ctrl+e"; "command" = "-workbench.action.quickOpen"; }
      { "key" = "ctrl+shift+c"; "command" = "-workbench.action.terminal.openNativeConsole"; "when" = "!terminalFocus"; }
    ];
    userSettings = {
      "telemetry.enableTelemetry" = false;
      "telemetry.enableCrashReporter" = false;
      "workbench.enableExperiments" = false;
      "workbench.settings.enableNaturalLanguageSearch" = false;

      "vscode-neovim.neovimExecutablePaths.linux" = "${pkgs.neovim}/bin/nvim";

      "workbench.colorTheme" = "Monokai";

      "editor.codeActionsOnSave" = {
        "source.fixAll" = true;
      };

      "editor.lineNumbers" = "relative";
      "editor.renderFinalNewline" = false;
      "files.insertFinalNewline" = true;
      "diffEditor.ignoreTrimWhitespace" = false;
      "trailing-spaces.trimOnSave" = true;
      "trailing-spaces.highlightCurrentLine" = false;

      "colorize.include" = [ "*" ];
      "colorize.colorized_colors" = [ "HEXA" "ARGB" "RGB" "HSL" ];
      "colorize.hide_current_line_decorations" = false;

      "terminal.external.linuxExec" = "termite";
    };
  };

  xsession.windowManager.i3 = mkIf using.i3 {
    enable = true;
    config = {
      bars = [];
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
  };

services.polybar = mkIf using.i3 {
  enable = true;
  package = pkgs.polybar.override { i3Support = true; };
  config = {
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
      height = mkIf using.hidpi 54;

      font-0 = mkIf using.hidpi "Fira Mono:pixelsize=20;1";
      font-1 = mkIf using.hidpi "Font Awesome 5 Free:style=Solid:pixelsize=20;1";

      tray-position = "right";
      tray-scale = mkIf using.hidpi "1.0";
      tray-maxsize = mkIf using.hidpi 54;
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
        # get latest commit hash for dotfiles
        LATEST=$(${pkgs.curl}/bin/curl -s https://github.com/Enzime/dotfiles-nix/commit/HEAD.patch | ${pkgs.coreutils}/bin/head -n 1 | ${pkgs.coreutils}/bin/cut -d ' ' -f 2)

        # get commit hash of currently running dotfiles
        cd /nix/var/nix/profiles/per-user/enzime/home-manager/dotfiles/
        RUNNING=$(${pkgs.git}/bin/git rev-parse HEAD)

        UPDATE_FOUND=false

        if ! ${pkgs.git}/bin/git merge-base --is-ancestor $LATEST $RUNNING 2>/dev/null; then
          UPDATE_FOUND=true
        fi

        if [[ $UPDATE_FOUND == "true" ]]; then
          echo  $(echo $LATEST | ${pkgs.coreutils}/bin/cut -c -7)
        else
          echo  $(echo $(${pkgs.git}/bin/git describe --always --dirty))
        fi
      ''}";
      interval = 300;
    };
  };
  script = ''
    polybar centre &
  '';
};

  programs.termite = mkIf using.i3 {
    enable = true;
    font = "DejaVu Sans Mono 10";
    colorsExtra = ''
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
    scrollbackLines = -1;
  };

  dconf.settings = mkIf using.gnome {
    "org/gnome/desktop/interface" = {
      clock-show-seconds = true;
      clock-show-weekday = true;
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" ];
      home = [ "<Super>e" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>t";
      command = "gnome-terminal";
      name = "Launch Terminal";
    };

    "org/gnome/terminal/legacy" = {
      theme-variant = "dark";
    };
  };

  xdg.configFile."ranger/rc.conf".text = ''
    set preview_images true

    set dirname_in_tabs true

    map      q  eval fm.notify("Use ZQ to quit")
    map      ZQ eval cmd("quitall") if not len(fm.loader.queue) else fm.notify("Use <C-c> to cancel currently running task")
    copymap  q Q ZZ

    map MF  console touch%space
    map MD  console mkdir%space
    map MM  console mark%space

    map T   tag_toggle
    map uT  tag_remove

    unmap gL
    map ga  cd -r .
    map gc  cd ~/.config
    map gC  eval fm.cd(ranger.CONFDIR)
    map gd  cd /data
    map gD  cd /dev
    map gH  cd /home
    map gl  cd ~/.local/share
    map gn  cd /nix

    map C   eval fm.open_console('rename ')
    map cw  bulkrename

    unmap <C-n>
    map <C-t>   tab_new ~
    map <C-f>   tab_move 1
    map <C-a>   tab_move -1
    map t<bg>   draw_bookmarks
    map t<any>  eval fm.tab_new(path=fm.bookmarks[str(fm.ui.keybuffer)[-1]])
    map t.      tab_new .
    map dt      tab_close
    map ut      tab_restore

    # M A G I C
    # `tg<any>` makes a new tab then goes to the folder specified by `g<any>`
    eval -q [cmd("map tg{} eval fm.tab_new(path='{}')".format(chr(k), fm.ui.keymaps['browser'][103][k][3:]))for k in fm.ui.keymaps['browser'][103] if fm.ui.keymaps['browser'][103][k].startswith('cd ')]

    ### GNOME TERMINAL
    # <backspace>   = <C-h>
    # <backspace2>  = <BS>
    #
    ### TERMITE
    # <backspace>   = <BS> | <C-h>

    # Use `zh` to toggle hidden
    unmap <backspace> <backspace2>

    map zF  filter
    map zz  console flat%space

    map ,R  source ~/.config/ranger/rc.conf

    # TODO: fix
    cmap <C-left>   eval fm.ui.console.move_word(left=1)
    cmap <C-right>  eval fm.ui.console.move_word(right=1)
  '';

  programs.mpv = {
    enable = true;

    bindings = {
      "BS" = "cycle pause";
      "SPACE" = "cycle pause";

      "\\" = "set speed 1.0";

      "UP" = "add volume 2";
      "DOWN" = "add volume -2";

      "PGUP" = "add chapter -1";
      "PGDWN" = "add chapter 1";

      "MOUSE_BTN3" = "add volume 2";
      "MOUSE_BTN4" = "add volume -2";

      "MOUSE_BTN7" = "add chapter -1";
      "MOUSE_BTN8" = "add chapter 1";

      "Alt+RIGHT" = "add video-rotate 90";
      "Alt+LEFT" = "add video-rotate -90";

      "h" = "seek -5";
      "j" = "add volume -2";
      "k" = "add volume 2";
      "l" = "seek 5";

      "Shift+LEFT" = "seek -60";
      "Shift+RIGHT" = "seek +60";

      "Z-Q" = "quit";

      "Ctrl+h" = "add chapter -1";
      "Ctrl+j" = "repeatable playlist-prev";
      "Ctrl+k" = "repeatable playlist-next";
      "Ctrl+l" = "add chapter 1";

      "J" = "cycle sub";
      "L" = "ab_loop";

      "a" = "add audio-delay -0.001";
      "s" = "add audio-delay +0.001";

      "O" = "cycle osc; cycle osd-bar";
    };

    config = {
      volume = 50;
      volume-max = 200;
      force-window = "yes";
      keep-open = "yes";
      osc = "no";
      osd-bar = "no";
    };
  };

  programs.feh = mkIf using.i3 {
    enable = true;
    buttons = {
      zoom_in = 4;
      zoom_out = 5;
    };

    keybindings = {
      save_image = null;
      delete = null;
    };
  };

  services.redshift = mkIf using.i3 {
    enable = true;
    temperature = {
      day = 5700;
      night = 3500;
    };
    latitude = "-38.0";
    longitude = "145.2";
  };

  systemd.user.startServices = "sd-switch";

  systemd.user.services = {
    shairport-sync = {
      Unit = {
        Description = "shairport-sync";
        After = [ "network.target" "avahi-daemon.service" ];
      };
      Service = {
        # Arguments are taken directly from:
        # https://github.com/NixOS/nixpkgs/blob/HEAD/nixos/modules/services/networking/shairport-sync.nix#L32
        ExecStart = "${pkgs.shairport-sync}/bin/shairport-sync -v -o pa";
        RuntimeDirectory = "shairport-sync";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };

  services.udiskie.enable = true;

  home.file.".mozilla/native-messaging-hosts/ff2mpv.json".source = "${pkgs.ff2mpv}/lib/mozilla/native-messaging-hosts/ff2mpv.json";

  programs.home-manager.enable = true;
} (import (./hosts + "/${hostname}/home.nix") { inherit lib pkgs; }) ]
