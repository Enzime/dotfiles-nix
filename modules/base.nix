{
  nixosModule = { config, configRevision, pkgs, lib, ... }: {
    # Ensure exact version of Nix has been manually verified
    nix.extraOptions = (assert (lib.hasPrefix "2.5.1-" pkgs.nix.version); ''
      experimental-features = nix-command flakes
    '');

    # Add flake revision to `nixos-version --json`
    system.configurationRevision = configRevision.full;

    system.extraSystemBuilderCmds = "ln -sv ${./.} $out/dotfiles";

    time.timeZone = "Australia/Melbourne";
    i18n.defaultLocale = "en_AU.UTF-8";

    environment.systemPackages = builtins.attrValues {
      inherit (pkgs) wget ranger;
    };

    programs.zsh.enable = true;
    programs.neovim.enable = true;
    programs.neovim.vimAlias = true;

    # Setting `useDHCP` globally is deprecated
    # manually set `useDHCP` for individual interfaces
    networking.useDHCP = false;

    services.openssh.enable = true;

    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;

    # On first setup, run `nixos-enter` then `passwd enzime`.
    users.users.enzime = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
    };

    # Taken directly from:
    # https://github.com/NixOS/nixpkgs/blob/HEAD/nixos/modules/services/networking/shairport-sync.nix#L74-L93
    services.avahi.enable = true;
    services.avahi.publish.enable = true;
    services.avahi.publish.userServices = true;

    networking.firewall.allowedTCPPorts = [ 5000 ];
    networking.firewall.allowedUDPPortRanges = [ { from = 6001; to = 6011; } ];
  };

  hmModule = { pkgs, lib, ... }: let
    inherit (lib) attrByPath hasPrefix mkIf mkMerge readFile;
  in {
    # Replace `with pkgs;` with `inherit (pkgs)`
    # https://nix.dev/anti-patterns/language#with-attrset-expression
    home.packages = builtins.attrValues {
      inherit (pkgs) peco ripgrep jq htop ranger comma;
    };

    # Ensure exact version of Nix has been manually verified
    xdg.configFile."nix/nix.conf".text = (assert (hasPrefix "2.5.1-" pkgs.nix.version); ''
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

    xdg.configFile."git/hooks/pre-commit".source = ../files/no-todo.sh;

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

      initExtra = readFile ../files/zshrc;

      shellAliases = {
        _ = "\\sudo ";
        sudo = "printf \"zsh: command not found: sudo\\n\"";

        ls = "ls -F --color=auto";
        mkdir = "mkdir -p";  # the only thing that was useful from the `utility` module

        l = "ls -lah";
        sr = "_ ranger";

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
        grias = "gri --autostash";
        gRh = "git reset --hard";
        gRs = "git reset --soft";
        gRv = "gR -v";
        gs = "git status";
        gsc = "gfc --depth=1";
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
    '' + readFile ../files/init.vim;

    xdg.configFile."ranger/rc.conf".source = ../files/rc.conf;
    xdg.configFile."ranger/commands.py".source = ../files/commands.py;

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

    programs.home-manager.enable = true;
  };
}
