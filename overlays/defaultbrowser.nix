self: super: {
  defaultbrowser = assert (!super ? defaultbrowser); super.stdenv.mkDerivation (let
    pname = "defaultbrowser";
  in {
    inherit pname;
    version = "unstable-2020-07-23";

    src = super.fetchFromGitHub {
      owner = "kerma";
      repo = pname;
      rev = "d2860c00dd7fbb5d615232cc819d7d492a6a6ddb";
      sha256 = "sha256-SelUQXoKtShcDjq8uKg3wM0kG2opREa2DGQCDd6IsOQ=";
    };

    makeFlags = [ "CC=cc" "PREFIX=$(out)" ];

    buildInputs = builtins.attrValues {
      inherit (super.darwin.apple_sdk.frameworks) Foundation;
    };
  });
}
