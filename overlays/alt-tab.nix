self: super: {
  alt-tab-macos =
    assert !(super.lib.hasInfix "-target" super.alt-tab-macos.buildPhase);
    super.alt-tab-macos.overrideAttrs (old: {
      buildPhase =
        let
          inherit (super.stdenv.hostPlatform) darwinArch darwinMinVersion;
        in
        builtins.replaceStrings
          [
            "declare -a commonSwiftFlags=("
            "-framework ScreenCaptureKit"
          ]
          [
            # Nixpkgs doesn't pass `-target` to `swiftc`, so it defaults to the build machine's macOS
            # version, builds from macOS 26 strongly link macOS 26 only APIs like `NSGlassEffectView`
            # which makes AltTab crash on launch on older versions of macOS
            "declare -a commonSwiftFlags=(-target ${darwinArch}-apple-macos${darwinMinVersion} "

            # https://github.com/lwouis/alt-tab-macos/blob/56891e08861e2d43fafb31d58a4c7fd9ba2289ec/config/base.xcconfig#L24
            "-Xlinker -weak_framework -Xlinker ScreenCaptureKit"
          ]
          old.buildPhase;
    });
}
