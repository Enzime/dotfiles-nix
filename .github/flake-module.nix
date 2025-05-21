{ self, ... }: {
  perSystem = { pkgs, ... }: {
    packages.github-actions-nix-config = pkgs.writeTextFile {
      name = "github-actions-nix.conf";
      text = let cfg = self.nixosConfigurations.phi-nixos.config.nix.settings;
      in ''
        substituters = ${toString cfg.substituters}
        trusted-public-keys = ${toString cfg.trusted-public-keys}
      '';
    };
  };
}
