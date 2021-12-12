
self: super: {
  comma = (assert (!builtins.hasAttr "comma" super); super.stdenv.mkDerivation (
    let
      pname = "comma";
      version = "1.0.0";
    in {
      inherit pname version;

      src = super.fetchFromGitHub {
        owner = "nix-community";
        repo = pname;
        rev = version;
        sha256 = "sha256-IT7zlcM1Oh4sWeCJ1m4NkteuajPxTnNo1tbitG0eqlg=";
      };

      patches = [
        (super.fetchpatch {
          name = "support-nix-2.4.patch";
          url = "https://github.com/nix-community/comma/commit/ca8998f4377afcab5904b29ea88fe329716535c8.patch";
          sha256 = "sha256-e8ic2swpUNLEQ/uBQx9vD7FEBw6aloZ5mPexcsf9oFw=";
        })
      ];

      postPatch = ''
        substituteInPlace , \
          --replace '--db "''${NIX_INDEX_DB}"' "" \
          --replace nix-locate "${super.nix-index}/bin/nix-locate" \
          --replace fzy "${super.fzy}/bin/fzy"
      '';

      nativeBuildInputs = [ super.makeWrapper ];
      buildInputs = [ super.nix-index super.fzy ];

      installPhase = ''
        install -Dm755 , -t $out/bin
        ln -s $out/bin/, $out/bin/comma
      '';
    }
  ));
}
