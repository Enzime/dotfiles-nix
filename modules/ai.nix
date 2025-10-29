{
  homeModule = { pkgs, ... }: {
    home.packages = builtins.attrValues { inherit (pkgs) claude-code; };

    home.file.".claude/CLAUDE.md".source = ../files/CLAUDE.md;
  };
}
