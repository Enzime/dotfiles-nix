{
  homeModule = { inputs, pkgs, ... }: {
    home.packages = builtins.attrValues {
      inherit (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system})
        claude-code;
    };

    home.file.".claude/CLAUDE.md".source = ../files/CLAUDE.md;
  };
}
