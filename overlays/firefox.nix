self: super: {
  firefox-bin-unwrapped = super.firefox-bin-unwrapped.overrideAttrs
    (old: { dontFixup = assert !old ? dontFixup; true; });
}
