self: super: let
  storeNewGeneration = super.writeShellScript "store-new-generation" (builtins.readFile ../files/store-new-generation.sh);
in {
  nixos-rebuild = super.nixos-rebuild.overrideAttrs (old: {
    postInstall = ''
      patch --no-backup-if-mismatch $target ${(super.substituteAll {
        src = ../files/nixos-rebuild.patch;
        inherit storeNewGeneration;
      })}
    '';
  });
}
