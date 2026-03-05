self: super:
let
  version = "0.0.1-rc39";

  sources = {
    x86_64-linux = {
      url = "https://sprites-binaries.t3.storage.dev/client/v${version}/sprite-linux-amd64.tar.gz";
      hash = "sha256-jc/NC62zu6/cPjXOtWRbt/xgduE3mKr6W/trfMrBa5Y=";
    };
    aarch64-linux = {
      url = "https://sprites-binaries.t3.storage.dev/client/v${version}/sprite-linux-arm64.tar.gz";
      hash = "sha256-3eAE8oh/wn/2sBB7CgnbPyugM3TS6wetpEoi+LmtBwk=";
    };
    x86_64-darwin = {
      url = "https://sprites-binaries.t3.storage.dev/client/v${version}/sprite-darwin-amd64.tar.gz";
      hash = "sha256-VTKOBfWqJVyV182KI63Viaw7W9yVjGz9P4uJT7STKgM=";
    };
    aarch64-darwin = {
      url = "https://sprites-binaries.t3.storage.dev/client/v${version}/sprite-darwin-arm64.tar.gz";
      hash = "sha256-maYdqZP4PLheuMVwZoyf/S7+8j47+LSsZrSf8KWoCsc=";
    };
  };

  src = super.fetchurl sources.${super.stdenv.hostPlatform.system};
in
{
  sprites = super.stdenvNoCC.mkDerivation {
    pname = "sprites";
    inherit version src;

    sourceRoot = ".";

    nativeBuildInputs = super.lib.optionals super.stdenv.hostPlatform.isLinux [
      super.autoPatchelfHook
    ];

    installPhase = ''
      install -Dm755 sprite $out/bin/sprite
    '';

    meta = {
      description = "Sprite CLI - cloud development environments";
      homepage = "https://sprites.dev";
      platforms = builtins.attrNames sources;
      mainProgram = "sprite";
    };
  };
}
