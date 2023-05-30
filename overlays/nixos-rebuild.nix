self: super: {
  store-new-generation = super.runCommand "patch-shebang" { } ''
    cp ${../files/store-new-generation.sh} $out
    patchShebangs $out
  '';

  nixos-rebuild = super.nixos-rebuild.overrideAttrs (old: {
    postInstall = ''
      patch --no-backup-if-mismatch $target ${
        (super.substituteAll {
          src = ../files/nixos-rebuild.patch;
          storeNewGeneration = self.store-new-generation;
        })
      }
    '';
  });
}
