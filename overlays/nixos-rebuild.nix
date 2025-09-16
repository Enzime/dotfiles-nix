self: super: {
  nixos-rebuild = super.nixos-rebuild.overrideAttrs (old:
    let
      patches = [
        (super.fetchpatch {
          name = "fix-cross-building-flakes.patch";
          url =
            "https://github.com/Enzime/nixpkgs/commit/8f7debeafaff06c2a5f039402d207712f2001770.patch";
          hash = "sha256-7ZS6RLqrekftJVx4C/OSLcESAwS5kaIxw9tujkI4YXo=";
        })
      ];
    in {
      postInstall = builtins.concatStringsSep "\n" ((map (p: ''
        echo "applying patch ${p}"
        patch --no-backup-if-mismatch $target ${p}'') patches)
        ++ [ (old.postInstall or "") ]);
    });
}
