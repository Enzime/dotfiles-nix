{
  homeModule =
    {
      config,
      inputs,
      lib,
      pkgs,
      ...
    }:
    let
      claude-code =
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code.overrideAttrs
          (old: {
            doInstallCheck =
              assert pkgs.stdenv.hostPlatform.system == "aarch64-darwin" -> old.doInstallCheck;
              pkgs.stdenv.hostPlatform.isLinux;

            # WORKAROUND: https://github.com/anthropics/claude-code/issues/92278
            nativeBuildInputs =
              old.nativeBuildInputs
              ++ lib.optional pkgs.stdenv.hostPlatform.isDarwin pkgs.darwin.autoSignDarwinBinariesHook;

            postInstall =
              (old.postInstall or "")
              + lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
                # Both checks fail the build once upstream touches any of this,
                # so the workaround gets dropped instead of silently living on.
                grep -qaF 'ENOTDIR")return null;return{stdout:null,unreadReason:' $out/bin/claude || {
                  echo "claude-code: EACCES is no longer fatal, drop this workaround" >&2
                  exit 1
                }

                found=$(grep -oaF '/Library/Managed Preferences/' $out/bin/claude | wc -l)
                [ "$found" -eq 3 ] || {
                  echo "claude-code: expected 3 managed preferences paths, found $found" >&2
                  exit 1
                }

                sed -i 's|/Library/Managed Preferences/|/Library/Managed-Preferences/|g' $out/bin/claude
              '';
          });

      omp = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp.overrideAttrs (old: {
        doInstallCheck =
          assert pkgs.stdenv.hostPlatform.system == "aarch64-darwin" -> old.doInstallCheck;
          pkgs.stdenv.hostPlatform.isLinux;
      });
    in
    {
      home.packages = builtins.attrValues (
        {
          inherit (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system})
            ccstatusline
            tuicr
            ;

          inherit (pkgs) herdr sprites;

          inherit claude-code omp;
        }
        // (lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          inherit (inputs.claude-code-sandbox.packages.${pkgs.stdenv.hostPlatform.system})
            default
            ;

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
        })
      );

      home.file.".claude/CLAUDE.md".source = ../files/CLAUDE.md;

      home.file.".claude/settings.json".text = lib.generators.toJSON { } {
        permissions = {
          allow = [ ];
          defaultMode = "default";
        };
        enabledPlugins = {
          "pyright-lsp@claude-plugins-official" = true;
        };
        alwaysThinkingEnabled = true;
        effortLevel = "high";
        cleanupPeriodDays = 99999;
        hooks = {
          Stop = [
            {
              matcher = "";
              hooks = [
                {
                  type = "command";
                  command = lib.getExe (
                    pkgs.writeShellApplication {
                      name = "jj-status-hook";
                      runtimeInputs = [ config.programs.jujutsu.package ];
                      text = ''
                        if jj root &>/dev/null; then
                          jj status
                        fi
                      '';
                    }
                  );
                }
              ];
            }
          ];
        };
        statusLine = {
          type = "command";
          command = lib.getExe inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.ccstatusline;
          padding = 0;
        };
      };
    };
}
