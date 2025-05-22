{ self, ... }: {
  perSystem = { pkgs, lib, ... }: {
    packages.github-actions-nix-config = pkgs.writeTextFile {
      name = "github-actions-nix.conf";
      text = let
        cfg = self.nixosConfigurations.eris.config.nix.settings;
        substituters =
          lib.filter (value: !lib.hasInfix "clan.lol" value) cfg.substituters;
      in ''
        substituters = ${toString substituters}
        trusted-public-keys = ${toString cfg.trusted-public-keys}
      '';
    };
  };
}
