{
  perSystem =
    {
      self',
      inputs',
      pkgs,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        buildInputs = builtins.attrValues {
          inherit (inputs'.home-manager.packages) home-manager;
          inherit (self'.packages) tf;

          clan-cli = inputs'.clan-core.packages.clan-cli.override {
            nix = pkgs.lixPackageSets.latest.lix;
          };
        };

        shellHook = ''
          if [[ -e $(git rev-parse --show-toplevel)/.git-blame-ignore-revs ]]; then
            git config --local blame.ignoreRevsFile .git-blame-ignore-revs
          fi
        '';
      };
    };
}
