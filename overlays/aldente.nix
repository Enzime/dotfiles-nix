self: super: {
  aldente =
    assert super.lib.versionOlder super.aldente.version "1.39.4";
    super.aldente.overrideAttrs (old: {
      version = "1.39.4";

      src = old.src.overrideAttrs {
        hash = "sha256-smNK5H9fhg+nX1vgqa6JsTbbtRQAOADtJWhz9DeqcBs=";
      };
    });
}
