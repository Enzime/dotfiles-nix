self: super: {
  # REMOVEME when https://github.com/NixOS/nixpkgs/pull/530348 is merged
  bitwarden-desktop =
    assert super.bitwarden-desktop.override.__functionArgs ? llvmPackages_18;
    (super.bitwarden-desktop.override {
      # easiest way to switch to latest LLVM
      llvmPackages_18 = { inherit (self) stdenv; };
    }).overrideAttrs
      (
        old:
        super.lib.optionalAttrs self.stdenv.hostPlatform.isDarwin (
          let
            electronVersionArg = "-c.electronVersion=${self.electron_39.version}";
            macIdentityArg = "-c.mac.identity=null";
          in
          assert !(super.lib.hasInfix macIdentityArg old.postBuild);
          {
            postBuild =
              builtins.replaceStrings
                [ electronVersionArg ]
                [ "${electronVersionArg} \\\n      ${macIdentityArg}" ]
                old.postBuild;
          }
        )
      );
}
