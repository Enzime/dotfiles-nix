self: super: {
  store-new-generation = super.writeShellScript "store-new-generation" (
    builtins.readFile ../files/store-new-generation.sh
  );

  nixos-rebuild = super.nixos-rebuild.overrideAttrs (old: {
    postInstall = ''
      patch --no-backup-if-mismatch $target ${(super.substituteAll {
        src = ../files/nixos-rebuild.patch;
        storeNewGeneration = self.store-new-generation;
      })}
    '';
  });
}
