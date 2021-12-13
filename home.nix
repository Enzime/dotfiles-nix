{ pkgs, lib, ... }:

let
  inherit (lib) attrByPath hasPrefix mkIf mkMerge readFile;
in {
  # Replace `with pkgs;` with `inherit (pkgs)`
  # https://nix.dev/anti-patterns/language#with-attrset-expression
  home.packages = builtins.attrValues {
    inherit (pkgs) peco ripgrep jq htop ranger comma;

    inherit (pkgs) _1password-gui qalculate-gtk pavucontrol;
  };

  # Ensure current version of Nix is exactly 2.4
  xdg.configFile."nix/nix.conf".text = (assert (hasPrefix "2.4-" pkgs.nix.version); ''
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

  programs.aria2.enable = true;
  programs.aria2.settings = {
    continue = true;
  };

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

  xdg.configFile."git/hooks/pre-commit".source = ./files/no-todo.sh;

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

    initExtra = readFile ./files/zshrc;

    shellAliases = {
      _ = "\\sudo ";
      sudo = "printf \"zsh: command not found: sudo\\n\"";

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
      gcf = "git commit --fixup";
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
      gRh = "git reset --hard";
      gRs = "git reset --soft";
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

  programs.nix-index.enable = true;

  programs.neovim.enable = true;
  programs.neovim.vimAlias = true;
  # Adding `vim-plug` to `plugins` does not load it, just source it directly instead
  programs.neovim.extraConfig = ''
    source ${pkgs.vimPlugins.vim-plug.rtp}/plug.vim
  '' + readFile ./files/init.vim;

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
      "update.mode" = "manual";
      "telemetry.telemetryLevel" = "off";
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

  xdg.configFile."ranger/rc.conf".source = ./files/rc.conf;
  xdg.configFile."ranger/commands.py".source = ./files/commands.py;

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
