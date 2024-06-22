self: super: {
  nixos-rebuild = super.nixos-rebuild.overrideAttrs (old:
    let
      patches = [
        (super.fetchpatch {
          name = "fix-cross-building-flakes.patch";
          url =
            "https://github.com/Enzime/nixpkgs/commit/6a504caae83fce4fe5e345f6c1ee4cf3f7f4fb09.patch";
          sha256 = "sha256-Rg+xo+Qr/TK5L8YBMnsIKoGwf0LHI/e+svJFvARtWnM=";
        })
      ];
    in {
      postInstall = builtins.concatStringsSep "\n" ((map (p: ''
        echo "applying patch ${p}"
        patch --no-backup-if-mismatch $target ${p}'') patches)
        ++ [ (old.postInstall or "") ]);
    });
}
