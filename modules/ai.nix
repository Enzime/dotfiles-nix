{
  homeModule = { config, inputs, lib, pkgs, ... }:
    let
      claude-code =
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code.overrideAttrs
        (old: {
          doInstallCheck = assert pkgs.stdenv.hostPlatform.system
            == "aarch64-darwin" -> old.doInstallCheck;
            pkgs.stdenv.hostPlatform.isLinux;
        });
    in {
      home.packages = builtins.attrValues ({
        inherit (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system})
          ccstatusline tuicr;

        inherit claude-code;
      } // (lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        inherit (inputs.claude-code-sandbox.packages.${pkgs.stdenv.hostPlatform.system})
          default;

        claude-code = pkgs.writeShellApplication {
          name = "claude";
          runtimeInputs = [
            inputs.claude-code-sandbox.packages.${pkgs.stdenv.hostPlatform.system}.default
            claude-code
          ];
          text = ''
            exec claude-sandbox claude --allow-dangerously-skip-permissions --permission-mode acceptEdits "$@"
          '';
        };

        claude-code-unsandboxed = pkgs.writeShellApplication {
          name = "claude-unsandboxed";
          runtimeInputs = [ claude-code ];
          text = ''
            exec claude "$@"
          '';
        };
      }));

      home.file.".claude/CLAUDE.md".source = ../files/CLAUDE.md;

      home.file.".claude/settings.json".text = lib.generators.toJSON { } {
        permissions = {
          allow = [ ];
          defaultMode = "default";
        };
        enabledPlugins = { "pyright-lsp@claude-plugins-official" = true; };
        alwaysThinkingEnabled = true;
        cleanupPeriodDays = 99999;
        hooks = {
          Stop = [{
            matcher = "";
            hooks = [{
              type = "command";
              command = lib.getExe (pkgs.writeShellApplication {
                name = "jj-status-hook";
                runtimeInputs = [ config.programs.jujutsu.package ];
                text = ''
                  if jj root &>/dev/null; then
                    jj status
                  fi
                '';
              });
            }];
          }];
        };
        statusLine = {
          type = "command";
          command = lib.getExe
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.ccstatusline;
          padding = 0;
        };
      };
    };
}
