{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    htop
    ranger
    peco
    neovim
  ];

  nixpkgs.overlays = [
    (self: super: {
      neovim = super.neovim.override { vimAlias = true; };
    })
  ];

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

    extraConfig = {
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

  programs.zsh = {
    enable = true;

    initExtraFirst = ''
      path=(
        /home/enzime/.nix-profile/bin
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

      unalias gfc
    '';

    shellAliases = {
      _ = "\\sudo ";
      sudo = "echo \"zsh: command not found: sudo\"";

      ls = "ls -F --color=auto";

      l = "ls -lah";
      ranger = "ranger-cd";

      gai = "git add --interactive";
      gbc = "gbfm -c";
      gbC = "gbfm -C";
      gbu = "git branch --set-upstream-to";
      gbv = "git branch -vv";
      gca = "git commit --amend";
      gco = "git checkout --patch";
      gC = "git checkout";
      gD = "git diff";
      gDs = "gD --cached";
      gf = "gfa --prune";
      gF = "git fetch";
      gln = "gl -n";
      gpd = "gp --delete";
      gRv = "gR -v";
      gs = "git status";
      gss = "git stash save -p";
      gsS = "git stash save --include-untracked";
      gS = "git show";
    };
  };

  dconf.settings = {
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

    map MF  console to uch%space
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

    # <backspace>   = <C-h>
    # <backspace2>  = <BS>
    # Use `zh` to toggle hidden
    unmap <backspace> <backspace2>

    map zF  filter
    map zz  console flat%space

    map ,R  source ~/.config/ranger/rc.conf

    # TODO: fix
    cmap <C-left>   eval fm.ui.console.move_word(left=1)
    cmap <C-right>  eval fm.ui.console.move_word(right=1)

    # Disable deleting characters with <C-h>
    uncmap <backspace>
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

  programs.home-manager.enable = true;
}
