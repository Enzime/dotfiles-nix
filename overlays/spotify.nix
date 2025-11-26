self: super:
super.lib.optionalAttrs super.stdenv.hostPlatform.isDarwin {
  spotify = super.spotify.overrideAttrs (old: {
    version = "1.2.74.477";

    src = super.fetchurl {
      inherit (old.src) url;
      hash = "sha256-0gwoptqLBJBM0qJQ+dGAZdCD6WXzDJEs0BfOxz7f2nQ=";
    };
  });
}
