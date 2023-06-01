let
  shared = { config, inputs, user, host, hostname, pkgs, lib, ... }: {
    networking.hostName = hostname;

    time.timeZone = "Australia/Melbourne";

    environment.systemPackages = (builtins.attrValues {
      inherit (pkgs) killall wget ranger zip unzip sshfs;
    }) ++ [
      inputs.home-manager.packages.${pkgs.system}.default
      inputs.agenix.packages.${pkgs.system}.default
      inputs.deploy-rs.packages.${pkgs.system}.default
    ];

    # Generate `/etc/nix/inputs/<input>` and `/etc/nix/registry.json` using FUP
    nix.linkInputs = true;
    nix.generateNixPathFromInputs = true;
    nix.generateRegistryFromInputs = true;

    nix.registry.d.to = {
      type = "git";
      url = "file://${config.users.users.${user}.home}/dotfiles";
    };
    nix.registry.n.to = {
      id = "nixpkgs";
      type = "indirect";
    };

    services.tailscale.enable = true;

    programs.zsh.enable = true;

    age.secrets.zshrc = let file = ../secrets/zshrc_${host}.age;
    in lib.mkIf (builtins.pathExists file) {
      inherit file;
      path = "${config.users.users.${user}.home}/.zshrc.secrets";
      owner = user;
    };
  };
in {
  imports = [
    "alacritty"
    "cachix"
    "flakes"
    "impermanence"
    "kitty"
    "nix-index"
    "termite"
    "vm"
    "vscode"
    "xdg"
  ];

  nixosModule = { config, configRevision, user, pkgs, ... }: {
    imports = [ shared ];

    # Add flake revision to `nixos-version --json`
    system.configurationRevision = configRevision.full;

    i18n.defaultLocale = "en_AU.UTF-8";

    environment.etc."nixos".source =
      "${config.users.users.${user}.home}/dotfiles";

    home-manager.users.root.home.stateVersion = "22.11";
    home-manager.users.root.programs.git.enable = true;
    home-manager.users.root.programs.git.extraConfig.safe.directory =
      "${config.users.users.${user}.home}/dotfiles";

    programs.neovim.enable = true;
    programs.neovim.vimAlias = true;
    programs.neovim.defaultEditor = true;

    # Setting `useDHCP` globally is deprecated
    # manually set `useDHCP` for individual interfaces
    networking.useDHCP = false;

    networking.firewall.trustedInterfaces =
      [ config.services.tailscale.interfaceName ];

    services.openssh.enable = true;
    services.openssh.settings.PermitRootLogin = "prohibit-password";

    # On first setup, run `nixos-enter` then `passwd <user>`.
    users.users.${user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
    };
  };

  darwinModule = { user, host, config, ... }: {
    imports = [ shared ];

    networking.computerName = host;

    users.users.${user}.home = "/Users/${user}";

    services.nix-daemon.enable = true;

    # WORKAROUND: Using MagicDNS (through nix-darwin) without setting a fallback
    # DNS server leads to taking a lot longer to connect to the internet.
    networking.dns = [ "1.1.1.1" ];

    services.tailscale.magicDNS.enable = true;

    # WORKAROUND: `systemsetup -f -setremotelogin on` requires `Full Disk Access`
    # permission for the Application calling it
    system.activationScripts.extraActivation.text = ''
      if [[ "$(systemsetup -getremotelogin | sed 's/Remote Login: //')" == "Off" ]]; then
        launchctl load -w /System/Library/LaunchDaemons/ssh.plist
      fi
    '';
  };

  hmModule = { config, inputs, pkgs, lib, ... }:
    let
      inherit (lib) mkIf readFile;
      inherit (pkgs.stdenv) hostPlatform;
    in {
      home.stateVersion = "22.11";

      # Replace `with pkgs;` with `inherit (pkgs)`
      # https://nix.dev/anti-patterns/language#with-attrset-expression
      home.packages = builtins.attrValues {
        inherit (pkgs)
          peco ripgrep jq htop ranger tmux tree magic-wormhole-rs hishtory;

        reptyr = mkIf hostPlatform.isLinux pkgs.reptyr;
      };

      # Allow fonts to be specified in `home.packages`
      fonts.fontconfig.enable = true;

      xdg.configFile."home-manager".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles";

      # Remove this once we have autoGenFromInputs for home-manager
      home.extraBuilderCommands =
        assert ((config.nix or { }) ? linkInputs == false);
        "ln -sv ${inputs.self} $out/dotfiles";

      home.sessionVariables = {
        EDITOR = "vim";
        VISUAL = "vim";
      };

      home.file.".ssh/config".text = ''
        Include config.local
      '';

      home.file.".wgetrc".text = ''
        content_disposition=on
        continue=on
        no_parent=on
        robots=off
      '';

      programs.aria2.enable = true;
      programs.aria2.settings = { continue = true; };

      programs.git = {
        enable = true;
        userName = "Michael Hoang";
        userEmail = "enzime@users.noreply.github.com";

        ignores = [ "/worktrees" "result" ];

        delta.enable = true;

        extraConfig = {
          advice = { addIgnoredFile = false; };
          am = { threeWay = true; };
          core = { hooksPath = "~/.config/git/hooks"; };
          diff = { colorMoved = "default"; };
          fetch = { prune = true; };
          init = { defaultBranch = "main"; };
          merge = { conflictStyle = "zdiff3"; };
          pull = { ff = "only"; };
          rebase = {
            autoStash = true;
            autoSquash = true;
          };
          url = {
            "https://github.com/" = { insteadOf = [ "gh:" "ghro:" ]; };
            "https://bitbucket.org/" = { insteadOf = [ "bb:" "bbro:" ]; };

            "ssh://git@github.com/" = {
              insteadOf = "ghp:";
              pushInsteadOf = "gh:";
            };
            "ssh://git@bitbucket.org/" = {
              insteadOf = "bbp:";
              pushInsteadOf = "bb:";
            };

            "___PUSH_DISABLED___" = { pushInsteadOf = [ "ghro:" "bbro:" ]; };
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

          pmoduleDirs = [ "${pkgs.zsh-you-should-use}/share/zsh/plugins" ];

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

        initExtra = readFile ../files/zshrc + ''
          source ${pkgs.hishtory}/share/hishtory/config.zsh
        '';

        shellAliases = {
          _ = "\\sudo ";
          sudo = ''printf "zsh: command not found: sudo\n"'';

          ls = "ls -F --color=auto";

          arg = "alias | rg --";
          l = "ls -lah";
          nb = "nix build";
          sr = "_ ranger";
          w = "where -s";

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
          gsc = "gfc --depth=1";
          gss = "git stash save -p";
          gsS = "git stash save --include-untracked";
          gS = "git show --stat --patch";
          gtx = "git tag --delete";
        };
      };

      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;

      programs.neovim.enable = true;
      programs.neovim.vimAlias = true;
      programs.neovim.plugins = [
        # Plugins that are always loaded
        pkgs.vimPlugins.vim-surround
        pkgs.vimPlugins.vim-repeat
        pkgs.vimPlugins.clever-f-vim
        pkgs.vimPlugins.vim-better-whitespace
        pkgs.vimPlugins.vim-sleuth
        pkgs.vimPlugins.vim-operator-user
        pkgs.vimPlugins.vim-operator-flashy
        pkgs.vimPlugins.vim-illuminate
        pkgs.vimPlugins.vim-argwrap
      ] ++ map (plugin: {
        inherit plugin;
        optional = true;
      }) [
        # Plugins for standalone Neovim
        pkgs.vimPlugins.hybrid-krompus-vim
        pkgs.vimPlugins.neovim-ranger

        pkgs.vimPlugins.denite-nvim
        pkgs.vimPlugins.editorconfig-nvim
        pkgs.vimPlugins.lightline-vim
        pkgs.vimPlugins.vim-commentary
        pkgs.vimPlugins.vim-css-color
        pkgs.vimPlugins.vim-fugitive
        pkgs.vimPlugins.vim-signature
        pkgs.vimPlugins.undotree

        pkgs.vimPlugins.ale
        pkgs.vimPlugins.vim-beancount
        pkgs.vimPlugins.vim-cpp-enhanced-highlight
        pkgs.vimPlugins.vim-javascript
        pkgs.vimPlugins.vim-jsx-pretty
        pkgs.vimPlugins.vim-nix
      ];
      programs.neovim.extraConfig = readFile ../files/init.vim;

      xdg.dataFile."nvim/rplugin.vim".source =
        pkgs.runCommand "update-remote-plugins" { } ''
          NVIM_RPLUGIN_MANIFEST=$out timeout 2s ${config.programs.neovim.finalPackage}/bin/nvim \
            -i NONE \
            -n \
            -u ${
              pkgs.writeText "init.lua"
              config.xdg.configFile."nvim/init.lua".text
            } \
            -c UpdateRemotePlugins \
            -c quit
        '';

      xdg.configFile."ranger/rc.conf".source = ../files/rc.conf;
      xdg.configFile."ranger/commands.py".source = ../files/commands.py;

      systemd.user.startServices = mkIf hostPlatform.isLinux "sd-switch";

      programs.home-manager.enable = true;
    };
}
