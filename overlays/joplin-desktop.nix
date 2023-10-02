self: super: {
  # Ensure the version of `joplin-desktop` in Nixpkgs is before 2.12.18
  joplin-desktop =
    assert super.lib.hasSuffix "2.12.16" super.joplin-desktop.name;
    (super.joplin-desktop.overrideAttrs (old:
      (let
        version = "2.12.18";

        throwSystem = throw "computer says no";

        suffix = {
          x86_64-linux = ".AppImage";
          x86_64-darwin = ".dmg";
          aarch64-darwin = "-arm64.dmg";
        }.${super.system} or throwSystem;
      in {
        inherit version;

        src = super.fetchurl {
          url =
            "https://github.com/laurent22/joplin/releases/download/v${version}/Joplin-${version}${suffix}";
          sha256 = {
            x86_64-linux =
              "1fwcqgqni7d9x0prdy3p8ccc5lzgn57rhph4498vs1q40kyq8823";
            x86_64-darwin =
              "sha256-atd7nkefLvilTq39nTLbXQhm1zzBCHOLL7MRJwlTSMk=";
            aarch64-darwin =
              "sha256-xiWXD+ULSVJ80uruYz0uRFkDRT1QOUd6FSWDKK9yLMc=";
          }.${super.system} or throwSystem;
        };
      })));
}
