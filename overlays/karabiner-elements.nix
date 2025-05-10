self: super: {
  karabiner-elements = super.karabiner-elements.overrideAttrs (old: {
    version = "14.13.0";

    src = super.fetchurl {
      inherit (old.src) url;
      hash = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
    };

    dontFixup = true;
  });
}
