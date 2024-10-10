self: super:
super.lib.optionalAttrs super.stdenv.hostPlatform.isDarwin {
  vscode = super.vscode.overrideAttrs (old: {
    postPatch =
      assert (builtins.match ".*asar.unpacked.*" old.postPatch) != null;
      builtins.replaceStrings [ ".asar.unpacked" ] [ "" ] old.postPatch;
  });
}
