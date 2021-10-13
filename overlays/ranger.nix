self: super: {
  ranger = super.ranger.overrideAttrs (old: {
    propagatedBuildInputs = (
    # Ensure no clipboard management tool is already specified
      assert (
        super.lib.mutuallyExclusive [ super.xclip super.xsel super.wl-clipboard ] old.propagatedBuildInputs
      ); old.propagatedBuildInputs ++ [ super.xclip ]
    );
  });
}
