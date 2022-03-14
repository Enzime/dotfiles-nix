{
  hmModule = { config, pkgs, lib, ... }: let
    inherit (pkgs.stdenv) hostPlatform;
  in {
    home.file.".vscode-server/extensions".source = config.home.file.".vscode/extensions".source;

    programs.vscode.enable = true;
    # Don't install `vscode` unless `graphical` module is specified
    programs.vscode.package = lib.mkDefault (pkgs.emptyDirectory // { pname = "vscode"; });
    programs.vscode.extensions = [
      pkgs.vscode-extensions.asvetliakov.vscode-neovim
      pkgs.vscode-extensions.eamodio.gitlens
      (pkgs.vscode-extensions.ms-vscode-remote.remote-ssh.override { useLocalExtensions = true; })

      pkgs.vscode-extensions.bierner.comment-tagged-templates
      pkgs.vscode-extensions.bierner.emojisense
      pkgs.vscode-extensions.bierner.markdown-checkbox
      pkgs.vscode-extensions.bierner.markdown-emoji
      pkgs.vscode-extensions.bierner.markdown-preview-github-styles
      pkgs.vscode-extensions.editorconfig.editorconfig
      pkgs.vscode-extensions.kamikillerto.vscode-colorize
      pkgs.vscode-extensions.mkhl.direnv
      pkgs.vscode-extensions.shardulm94.trailing-spaces

      # Language support
      pkgs.vscode-extensions.dbaeumer.vscode-eslint
      pkgs.vscode-extensions.jnoortheen.nix-ide
      (lib.mkIf (!hostPlatform.isDarwin) pkgs.vscode-extensions.ms-python.python)
      pkgs.vscode-extensions.ms-python.vscode-pylance
      pkgs.vscode-extensions.ms-vscode.cpptools
      pkgs.vscode-extensions.xadillax.viml
    ];
    programs.vscode.keybindings = [
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

      # Don't hide terminal when using "C-`" to switch back to editor
      { key = "ctrl+`"; command = "-workbench.action.terminal.toggleTerminal"; when = "terminal.active"; }
      { key = "ctrl+`"; command = "terminal.focus"; when = "!terminalFocus"; }
      { key = "ctrl+`"; command = "workbench.action.focusActiveEditorGroup"; when = "terminalFocus"; }

      # Disable closing tabs with `C-w`
      { key = "ctrl+w"; command = "-workbench.action.closeActiveEditor"; }
      { key = "ctrl+w"; command = "-workbench.action.terminal.killEditor"; when = "terminalEditorFocus && terminalFocus && terminalHasBeenCreated && resourceScheme == 'vscode-terminal' || terminalEditorFocus && terminalFocus && terminalProcessSupported && resourceScheme == 'vscode-terminal'"; }

      # Disable `C-k` passthrough as VS Code uses `C-k` as the starting chord extensively
      { key = "ctrl+k"; command = "-vscode-neovim.send"; when = "editorTextFocus && neovim.ctrlKeysNormal && neovim.init && neovim.mode != 'insert'"; }

      # Use `C-S-k` for clearing the terminal
      { key = "ctrl+shift+k"; command = "-editor.action.deleteLines"; when = "textInputFocus && !editorReadonly"; }
      { key = "ctrl+shift+k"; command = "workbench.action.terminal.clear"; }

      # Disable `C-S-n` to reinforce `C-, C-r C-Enter` workflow
      { key = "ctrl+shift+n"; command = "-workbench.action.newWindow"; }

      # `C-i` is for IntelliSense suggestions
      { key = "ctrl+i"; command = "-emojisense.quickEmoji"; when = "editorTextFocus"; }
      { key = "ctrl+shift+i"; command = "-emojisense.quickEmojitext"; when = "editorTextFocus"; }
    ];
    programs.vscode.userSettings = {
      "update.mode" = "manual";
      "extensions.autoUpdate" = false;
      "extensions.autoCheckUpdates" = false;

      "telemetry.telemetryLevel" = "off";
      "workbench.enableExperiments" = false;
      "workbench.settings.enableNaturalLanguageSearch" = false;

      "vscode-neovim.neovimExecutablePaths.linux" = "${pkgs.neovim}/bin/nvim";
      "nix.enableLanguageServer" = true;

      "workbench.colorTheme" = "Monokai";
      "markdown-preview-github-styles.colorTheme" = "light";

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
      "files.exclude" = {
        "**/.direnv" = true;
      };

      # Don't use GitLens to edit git rebase commands
      "workbench.editorAssociations" = {
        "git-rebase-todo" = "default";
      };

      "editor.bracketPairColorization.enabled" = true;
      "editor.guides.bracketPairs" = true;
      "colorize.include" = [ "*" ];
      "colorize.colorized_colors" = [ "HEXA" "ARGB" "RGB" "HSL" ];
      "colorize.hide_current_line_decorations" = false;

      "terminal.external.linuxExec" = "termite";

      "files.associations" = {
        "*.lock" = "json";
      };
    };

    programs.git.extraConfig.core.editor = "${pkgs.writeShellScript "use-vscode-sometimes" ''
      if [[ $TERM_PROGRAM = "vscode" ]]; then
        code --wait "$@"
      else
        vim "$@"
      fi
    ''}";
  };
}
