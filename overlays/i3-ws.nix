self: super: {
  i3-ws = super.stdenv.mkDerivation {
    name = "i3-ws";
    src = super.fetchFromGitHub {
      owner = "Enzime";
      repo = "i3-ws";
      rev = "bca34b6b10509088ceac03fb9a1ef27808165ccb";
      sha256 = "1i014hsi80wsaxmdpl8ccwhpvnclkl14w4r0mbci3yqap8a32wgn";
      fetchSubmodules = true;
    };

    buildInputs = with super; [
      i3 jsoncpp libsigcxx
    ];

    nativeBuildInputs = with super; [
      cmake pkgconfig
    ];
  };
}
