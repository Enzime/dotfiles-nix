self: super: {
  i3-ws = assert !super ? i3-ws;
    super.stdenv.mkDerivation (finalAttrs: {
      pname = "i3-ws";
      version = "git-2017-07-30";

      src = super.fetchFromGitHub {
        owner = "Enzime";
        repo = finalAttrs.pname;
        rev = "bca34b6b10509088ceac03fb9a1ef27808165ccb";
        hash = "sha256-9nExFLoK+xHZqiATTgKdlNl9IWcM0dtqV5oDFDUkAcQ=";
        fetchSubmodules = true;
      };

      buildInputs =
        builtins.attrValues { inherit (super) i3 jsoncpp libsigcxx; };

      nativeBuildInputs =
        builtins.attrValues { inherit (super) cmake pkg-config; };

      meta.mainProgram = finalAttrs.pname;
    });
}
