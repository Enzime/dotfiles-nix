self: super: {
  i3-ws = assert !super ? i3-ws;
    super.stdenv.mkDerivation (let
      pname = "i3-ws";
      version = "git-2017-07-30";
    in {
      inherit pname version;

      src = super.fetchFromGitHub {
        owner = "Enzime";
        repo = pname;
        rev = "bca34b6b10509088ceac03fb9a1ef27808165ccb";
        hash = "1i014hsi80wsaxmdpl8ccwhpvnclkl14w4r0mbci3yqap8a32wgn";
        fetchSubmodules = true;
      };

      buildInputs =
        builtins.attrValues { inherit (super) i3 jsoncpp libsigcxx; };

      nativeBuildInputs =
        builtins.attrValues { inherit (super) cmake pkg-config; };

      meta.mainProgram = pname;
    });
}
