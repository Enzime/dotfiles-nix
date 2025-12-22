let
  shared = { config, user, ... }: {
    home-manager.users.root.programs.git.enable = true;
    home-manager.users.root.programs.git.settings.safe.directory =
      "${config.users.users.${user}.home}/dotfiles";
  };
in {
  nixosModule = shared;

  darwinModule = shared;

  homeModule = { pkgs, ... }: {
    home.packages = builtins.attrValues { inherit (pkgs) jjui watchman; };

    programs.git = {
      enable = true;

      ignores = [ "/worktrees" "/workspaces" "result*" ".DS_Store" ".claude" ];

      settings = {
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
        user = {
          name = "Michael Hoang";
          email = "enzime@users.noreply.github.com";
        };
      };
    };

    programs.zsh.shellAliases = {
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

    programs.jujutsu.enable = true;
    programs.jujutsu.settings = {
      user.name = "Michael Hoang";
      user.email = "enzime@users.noreply.github.com";

      fsmonitor.backend = "watchman";

      templates.draft_commit_description = ''
        concat(
          builtin_draft_commit_description,
          "JJ:\nJJ: ignore-rest\n",
          diff.git(),
        )
      '';

      ui.default-command = "log";
    };

    programs.delta.enable = true;
    programs.delta.enableGitIntegration = true;
  };
}
