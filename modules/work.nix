{
  nixosModule = { user, ... }: {
    age.secrets.aws_config = {
      file = ../secrets/aws_config.age;
      path = "/home/${user}/.aws/config";
      owner = user;
    };

    virtualisation.podman.enable = true;
    virtualisation.podman.dockerCompat = true;

    services.tailscale.enable = true;
  };

  hmModule = { pkgs, ... }: {
    home.packages = builtins.attrValues {
      inherit (pkgs) android-studio awscli2 aws-vault mongodb-compass postman remmina slack;
      inherit (pkgs.gnome) zenity;
    };

    programs.zsh.initExtra = ''
      export AWS_VAULT_PROMPT="zenity"
    '';

    home.sessionVariablesExtra = ''
      if [[ $XDG_SESSION_TYPE = "wayland" ]]; then
        export _JAVA_AWT_WM_NONREPARENTING=1
      fi
    '';

    programs.firefox.extensions = [
      pkgs.firefox-addons.react-devtools
      pkgs.firefox-addons.reduxdevtools
    ];

    programs.vscode.extensions = [
      pkgs.vscode-extensions.ethansk.restore-terminals
      pkgs.vscode-extensions.ms-vsliveshare.vsliveshare
      pkgs.vscode-extensions.octref.vetur
      pkgs.vscode-extensions.rioj7.commandOnAllFiles
    ];

    programs.vscode.userSettings = {
      "restoreTerminals.keepExistingTerminalsOpen" = true;
      "commandOnAllFiles.commands"."Trailing Spaces: Delete" = {
        "command" = "trailing-spaces.deleteTrailingSpaces";
        "includeFileExtensions" = [ ".js" ".json" ];
      };
    };
  };
}
