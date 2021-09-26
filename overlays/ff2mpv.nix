self: super: {
  ff2mpv = super.stdenv.mkDerivation rec {
    name = "ff2mpv";
    version = "3.8.0";

    src = super.fetchFromGitHub {
      owner = "woodruffw";
      repo = "ff2mpv";
      rev = "v${version}";
      sha256 = "1xmyzi671fny6z2445dp5lc02bdgaivpvn8y56g0p7jxs5rj9sbs";
    };

    buildInputs = builtins.attrValues {
      inherit (super) python3 mpv;
    };

    patchPhase = ''
      patchShebangs .
      substituteInPlace ff2mpv.json \
        --replace '/home/william/scripts/ff2mpv' "$out/bin/ff2mpv.py"
    '';

    installPhase = ''
      mkdir -p $out/bin $out/lib/mozilla/native-messaging-hosts
      cp ff2mpv.py $out/bin
      cp ff2mpv.json $out/lib/mozilla/native-messaging-hosts
    '';
  };
}
