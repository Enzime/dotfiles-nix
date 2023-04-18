{
  imports = [ "docker" ];

  darwinModule = { user, config, pkgs, ... }: {
    system.activationScripts.extraUserActivation.text = ''
      defaults write com.tinyspeck.slackmacgap SlackNoAutoUpdates -bool YES
    '';

    age.secrets.aws_config = {
      file = ../secrets/aws_config.age;
      path = "/Users/${user}/.aws/config";
      owner = user;
    };

    age.secrets.git_config = {
      file = ../secrets/git_config.age;
      path = "/Users/${user}/.config/git/config.work";
      owner = user;
    };

    age.secrets.npmrc = {
      file = ../secrets/npmrc.age;
      path = "/Users/${user}/.npmrc";
      owner = user;
    };

    age.secrets.ssh_allowed_signers = {
      file = ../secrets/ssh_allowed_signers.age;
      path = "/Users/${user}/.ssh/allowed_signers";
      owner = user;
    };
  };

  hmModule = { config, pkgs, lib, ... }: {
    home.packages = builtins.attrValues {
      inherit (pkgs) awscli2 aws-vault postman slack;
    };

    home.sessionVariables = {
      AWS_SDK_LOAD_CONFIG = 1;
    };

    programs.zsh.initExtra = ''
      function agenix {
          $(which -p agenix) $@ -i =(op read $OP_SSH_KEY_URL)
      }
    '';

    programs.git.includes = [
      { condition = "gitdir:~/Work/"; path = "~/.config/git/config.work"; }
    ];

    xdg.configFile."git/ignore.work".text = builtins.concatStringsSep "\n" (config.programs.git.ignores ++ [
      ".direnv/"
      ".envrc"
      "shell.nix"
    ]) + "\n";

    programs.firefox.profiles.default.extensions = [
      pkgs.firefox-addons.multi-account-containers
    ];

    programs.vscode.extensions = [
      pkgs.vscode-extensions.graphql.vscode-graphql
    ];

    programs.vscode.userSettings = {
      "typescript.preferences.importModuleSpecifier" = "relative";
    };

    home.file.".aws/credentials".text = "";
  };
}
