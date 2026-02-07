{
  homeModule = { config, inputs, lib, pkgs, ... }: {
    home.packages = builtins.attrValues {
      inherit (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system})
        ccstatusline ccusage;

      claude-code =
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code.overrideAttrs
        (old: {
          doInstallCheck = assert pkgs.stdenv.hostPlatform.system
            == "aarch64-darwin" -> old.doInstallCheck;
            pkgs.stdenv.hostPlatform.isLinux;
        });
    };

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
