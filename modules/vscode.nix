{
  darwinModule = {
    system.defaults.CustomUserPreferences."com.microsoft.VSCode"."ApplePressAndHoldEnabled" = false;
  };

  homeModule =
    {
      config,
      inputs,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (pkgs.stdenv) hostPlatform;
    in
    {
      home.file.".vscode-server/extensions".source = config.home.file.".vscode/extensions".source;

      programs.vscode.enable = true;
      # Don't install `vscode` unless `graphical` module is specified
      programs.vscode.package = lib.mkDefault (
        pkgs.emptyDirectory
        // {
          pname = "vscode";
          # Required for version check to generate extensions.json
          version = "1.74.0";
        }
      );
      programs.vscode.mutableExtensionsDir = false;
      programs.vscode.profiles.default.extensions = [
        pkgs.vscode-extensions.asvetliakov.vscode-neovim
        pkgs.vscode-extensions.eamodio.gitlens
        (pkgs.vscode-extensions.ms-vscode-remote.remote-ssh.override {
          useLocalExtensions = true;
        })

        pkgs.vscode-extensions.bierner.comment-tagged-templates
        pkgs.vscode-extensions.bierner.emojisense
        pkgs.vscode-extensions.bierner.markdown-checkbox
        pkgs.vscode-extensions.bierner.markdown-emoji
        pkgs.vscode-extensions.bierner.markdown-preview-github-styles
        pkgs.vscode-extensions.editorconfig.editorconfig
        pkgs.vscode-extensions.mkhl.direnv
        pkgs.vscode-extensions.shardulm94.trailing-spaces

        # Language support
        pkgs.vscode-extensions.dbaeumer.vscode-eslint
        pkgs.vscode-extensions.jnoortheen.nix-ide
        pkgs.vscode-extensions.xadillax.viml
        pkgs.vscode-extensions.nefrob.vscode-just-syntax
        pkgs.vscode-extensions.golang.go
      ]
      ++ lib.optionals (hostPlatform.isx86_64 || hostPlatform.isDarwin) [
        (pkgs.vscode-extensions.ms-python.python.override {
          pythonUseFixed = true;
        })
      ];
      programs.vscode.profiles.default.keybindings =
        let
          mod = if hostPlatform.isDarwin then "cmd" else "ctrl";
        in
        [
          # Fix `C-e` not working in terminal
          {
            key = "ctrl+e";
            command = "-workbench.action.quickOpen";
          }
          # Disable opening external terminal with `C-S-c`
          {
            key = "ctrl+shift+c";
            command = "-workbench.action.terminal.openNativeConsole";
            when = "!terminalFocus";
          }

          # Use `C-o` to open files
          {
            key = "ctrl+o";
            command = "-vscode-neovim.send";
            when = "editorTextFocus && neovim.ctrlKeysNormal && neovim.init && neovim.mode != 'insert'";
          }

          # Use `C-,` as a leader key
          {
            key = "ctrl+,";
            command = "-workbench.action.openSettings";
          }
          # Use `openSettings2` instead to show as the keybinding for "Open Settings (UI)"
          {
            key = "ctrl+, ctrl+,";
            command = "workbench.action.openSettings2";
          }
          {
            key = "ctrl+, ctrl+.";
            command = "workbench.action.openGlobalKeybindings";
          }

          # Use `C-r` solely for redoing in `neovim`
          {
            key = "ctrl+r";
            command = "-workbench.action.openRecent";
          }
          {
            key = "ctrl+, ctrl+r";
            command = "workbench.action.openRecent";
          }

          # Don't hide terminal when using "C-`" to switch back to editor
          {
            key = "ctrl+`";
            command = "-workbench.action.terminal.toggleTerminal";
            when = "terminal.active";
          }
          {
            key = "ctrl+`";
            command = "terminal.focus";
            when = "!terminalFocus";
          }
          {
            key = "ctrl+`";
            command = "workbench.action.focusActiveEditorGroup";
            when = "terminalFocus";
          }

          # Disable closing tabs with `C-w`
          {
            key = "ctrl+w";
            command = "-workbench.action.closeActiveEditor";
          }
          {
            key = "ctrl+w";
            command = "-workbench.action.terminal.killEditor";
            when = "terminalEditorFocus && terminalFocus && terminalHasBeenCreated && resourceScheme == 'vscode-terminal' || terminalEditorFocus && terminalFocus && terminalProcessSupported && resourceScheme == 'vscode-terminal'";
          }

          # Disable `C-k` passthrough as VS Code uses `C-k` as the starting chord extensively
          {
            key = "ctrl+k";
            command = "-vscode-neovim.send";
            when = "editorTextFocus && neovim.ctrlKeysNormal && neovim.init && neovim.mode != 'insert'";
          }

          # Use `C-S-k` for clearing the terminal
          {
            key = "ctrl+shift+k";
            command = "-editor.action.deleteLines";
            when = "textInputFocus && !editorReadonly";
          }
          {
            key = "ctrl+shift+k";
            command = "workbench.action.terminal.clear";
          }

          # Disable `C-S-n` to reinforce `C-, C-r C-Enter` workflow
          {
            key = "ctrl+shift+n";
            command = "-workbench.action.newWindow";
          }

          # `C-i` is for IntelliSense suggestions
          {
            key = "${mod}+i";
            command = "-emojisense.quickEmoji";
            when = "editorTextFocus";
          }
          {
            key = "${mod}+shift+i";
            command = "-emojisense.quickEmojitext";
            when = "editorTextFocus";
          }

          # Disable Tab Moves Focus mode
          {
            key = "ctrl+m";
            command = "-editor.action.toggleTabFocusMode";
          }
        ];
      programs.vscode.profiles.default.userSettings =
        let
          nvimSystem = if hostPlatform.isDarwin then "darwin" else "linux";
        in
        {
          "update.mode" = "manual";
          "extensions.autoUpdate" = false;
          "extensions.autoCheckUpdates" = false;

          "telemetry.telemetryLevel" = "off";
          "workbench.enableExperiments" = false;
          "workbench.settings.enableNaturalLanguageSearch" = false;

          "vscode-neovim.neovimExecutablePaths.${nvimSystem}" =
            lib.getExe config.programs.neovim.finalPackage;
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = lib.getExe pkgs.nil;
          "nix.serverSettings".nil.formatting.command = [
            (lib.getExe inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.cached-nix-fmt)
            "--stdin"
            "example.nix"
          ];
          "nix.serverSettings".nil.nix.flake.autoArchive = true;
          "extensions.experimental.affinity" = {
            "asvetliakov.vscode-neovim" = 1;
          };

          "workbench.colorTheme" = "Monokai";
          "markdown-preview-github-styles.colorTheme" = "light";

          "editor.formatOnSave" = true;
          # Primarily for ESLint
          "editor.codeActionsOnSave" = {
            "source.fixAll" = "explicit";
          };

          "editor.lineNumbers" = "relative";
          "editor.renderFinalNewline" = "off";
          "files.insertFinalNewline" = true;
          "diffEditor.diffAlgorithm" = "advanced";
          "diffEditor.ignoreTrimWhitespace" = false;
          "trailing-spaces.trimOnSave" = true;
          "trailing-spaces.highlightCurrentLine" = false;

          "search.useGlobalIgnoreFiles" = true;
          "files.exclude" = {
            "**/.direnv" = true;
            "**/.jj" = true;
          };

          # Don't use VS Code's 3 way merge editor
          "git.mergeEditor" = false;

          # Don't use GitLens to edit git rebase commands
          "workbench.editorAssociations" = {
            "git-rebase-todo" = "default";
          };

          "gitlens.remotes" = [
            {
              domain = "git.clan.lol";
              type = "Gitea";
            }
          ];

          # Don't warn when Git is disabled due to conflicts with jjk
          "gitlens.advanced.messages" = {
            "suppressGitDisabledWarning" = true;
            "suppressGitMissingWarning" = true;
          };

          "editor.bracketPairColorization.enabled" = true;
          "editor.guides.bracketPairs" = true;

          "terminal.integrated.scrollback" = 1000000;
          "terminal.integrated.stickyScroll.enabled" = false;

          "files.associations" = {
            "flake.lock" = "json";
            "yarn.lock" = "yaml";
            ".env.*" = "properties";
          };

          "workbench.colorCustomizations" = {
            "terminal.background" = "#0d0c0c";
            "terminal.foreground" = "#fff5ed";
            "terminalCursor.background" = "#F8F8F2";
            "terminalCursor.foreground" = "#00ccff";

            "terminal.ansiBlack" = "#0a0a0a";
            "terminal.ansiBrightBlack" = "#73645d";

            "terminal.ansiRed" = "#e61f00";
            "terminal.ansiBrightRed" = "#ff3f3d";

            "terminal.ansiGreen" = "#6dd200";
            "terminal.ansiBrightGreen" = "#c1ff05";

            "terminal.ansiYellow" = "#fa6800";
            "terminal.ansiBrightYellow" = "#ffa726";

            "terminal.ansiBlue" = "#255ae4";
            "terminal.ansiBrightBlue" = "#00ccff";

            "terminal.ansiMagenta" = "#ff0084";
            "terminal.ansiBrightMagenta" = "#ff65a0";

            "terminal.ansiCyan" = "#36fcd3";
            "terminal.ansiBrightCyan" = "#96ffe3";

            "terminal.ansiWhite" = "#b6afab";
            "terminal.ansiBrightWhite" = "#fff5ed";
          };

          # WORKAROUND: VS Code crashes when running under Wayland
          # https://github.com/NixOS/nixpkgs/issues/246509
          "window.titleBarStyle" = "custom";

          # Disable Copilot
          "terminal.integrated.initialHint" = false;
        };

      preservation.directories = [ ".config/Code" ];

      home.file.".vscode-server/data/Machine/settings.json".source =
        (pkgs.formats.json { }).generate "vscode-server-settings.json"
          {
            "nix.serverPath" = lib.getExe pkgs.nil;
          };

      programs.git.settings.core.editor = lib.getExe (
        pkgs.writeShellApplication {
          name = "use-vscode-sometimes";
          text = ''
            if [[ $TERM_PROGRAM = "vscode" ]]; then
              code --wait "$@"
            else
              vim "$@"
            fi
          '';
        }
      );

      programs.jujutsu.settings.ui.editor = config.programs.git.settings.core.editor;
    };
}
