{
  imports = [ "docker" ];

  hmModule = { pkgs, lib, ... }: {
    home.packages = builtins.attrValues {
      inherit (pkgs) awscli2 aws-vault postman slack;
    } ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux (builtins.attrValues {
      inherit (pkgs) android-studio mongodb-compass remmina;
      inherit (pkgs.gnome) zenity;
    });

    programs.zsh.initExtra = lib.mkIf pkgs.stdenv.hostPlatform.isLinux ''
      export AWS_VAULT_PROMPT="zenity"
    '';

    home.sessionVariablesExtra = lib.mkIf pkgs.stdenv.hostPlatform.isLinux ''
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
      (lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) pkgs.vscode-extensions.ms-vsliveshare.vsliveshare)
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
