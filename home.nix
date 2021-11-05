{ pkgs, lib, ... }:

let
  inherit (lib) attrByPath mkIf mkMerge readFile;
in {
  # Replace `with pkgs;` with `inherit (pkgs)`
  # https://nix.dev/anti-patterns/language#with-attrset-expression
  home.packages = builtins.attrValues {
    # Necessary for non-NixOS systems which won't have the flakiest version of Nix
    nixFlakes = (assert (builtins.compareVersions pkgs.nix.version "2.4") < 0; pkgs.nixFlakes);

    inherit (pkgs) peco ripgrep jq htop ranger;

    inherit (pkgs) _1password-gui qalculate-gtk pavucontrol;
  };

  xdg.configFile."nix/nix.conf".text = (assert (builtins.compareVersions pkgs.nix.version "2.4") < 0; ''
    experimental-features = nix-command flakes
  '');


  # Allow fonts to be specified in `home.packages`
  fonts.fontconfig.enable = true;

  home.extraBuilderCommands = "ln -sv ${./.} $out/dotfiles";

  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
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
          .direnv
          .envrc
          result
        ''}";
        hooksPath = "~/.config/git/hooks";
      };
      init = {
        defaultBranch = "main";
      };
      fetch = {
        prune = true;
      };
      rebase = {
        autoSquash = true;
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
    # If this option is not disabled
    # `home-manager` installs `nix-zsh-completions`
    # which conflicts with `nix` in `home.packages`
    enableCompletion = false;

    initExtraFirst = ''
      path=(
        ~/.nix-profile/bin
        $path
      )
    '';

    prezto = {
      enable = true;

      pmoduleDirs = [
        "${pkgs.zsh-you-should-use}/share/zsh/plugins"
      ];

      pmodules = [
        "environment"
        "terminal"
        "you-should-use"
        "editor"
        "history"
        "directory"
        "spectrum"
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

      # Allow using `#`, `~` and `^` without escape
      unsetopt EXTENDED_GLOB

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
      mkdir = "mkdir -p";  # the only thing that was useful from the `utility` module

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
  programs.direnv.nix-direnv.enableFlakes = true;

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
      pkgs.vscode-extensions.ms-python.python
      pkgs.vscode-extensions.ms-python.vscode-pylance
      pkgs.vscode-extensions.jnoortheen.nix-ide

      pkgs.vscode-extensions.kamikillerto.vscode-colorize
    ];
    keybindings = [
      # Fix `C-e` not working in terminal
      { key = "ctrl+e"; command = "-workbench.action.quickOpen"; }
      # Disable opening external terminal with `C-S-c`
      { key = "ctrl+shift+c"; command = "-workbench.action.terminal.openNativeConsole"; when = "!terminalFocus"; }

      # Use `C-o` to open files
      { key = "ctrl+o"; command = "-vscode-neovim.send"; when = "editorTextFocus && neovim.ctrlKeysNormal && neovim.init && neovim.mode != 'insert'"; }

      # Use `C-,` as a leader key
      { key = "ctrl+,"; command = "-workbench.action.openSettings"; }
      # Use `openSettings2` instead to show as the keybinding for "Open Settings (UI)"
      { key = "ctrl+, ctrl+,"; command = "workbench.action.openSettings2"; }
      { key = "ctrl+, ctrl+."; command = "workbench.action.openGlobalKeybindings"; }

      # Use `C-r` solely for redoing in `neovim`
      { key = "ctrl+r"; command = "-workbench.action.openRecent"; }
      { key = "ctrl+, ctrl+r"; command = "workbench.action.openRecent"; }
    ];
    userSettings = {
      "telemetry.enableTelemetry" = false;
      "telemetry.enableCrashReporter" = false;
      "workbench.enableExperiments" = false;
      "workbench.settings.enableNaturalLanguageSearch" = false;

      "vscode-neovim.neovimExecutablePaths.linux" = "${pkgs.neovim}/bin/nvim";

      "workbench.colorTheme" = "Monokai";

      "files.simpleDialog.enable" = true;

      "editor.codeActionsOnSave" = {
        "source.fixAll" = true;
      };

      "editor.lineNumbers" = "relative";
      "editor.renderFinalNewline" = false;
      "files.insertFinalNewline" = true;
      "diffEditor.ignoreTrimWhitespace" = false;
      "trailing-spaces.trimOnSave" = true;
      "trailing-spaces.highlightCurrentLine" = false;
      "search.useGlobalIgnoreFiles" = true;

      "colorize.include" = [ "*" ];
      "colorize.colorized_colors" = [ "HEXA" "ARGB" "RGB" "HSL" ];
      "colorize.hide_current_line_decorations" = false;

      "terminal.external.linuxExec" = "termite";
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
    map gn  cd /etc/nix
    map gN  cd /nix/var/nix

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

  systemd.user.startServices = "sd-switch";

  systemd.user.services.shairport-sync = {
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

  home.file.".mozilla/native-messaging-hosts/ff2mpv.json".source = "${pkgs.ff2mpv}/lib/mozilla/native-messaging-hosts/ff2mpv.json";

  programs.home-manager.enable = true;
}
