self: super: {
  mas = assert !super.mas.meta ? mainProgram;
    super.mas.overrideAttrs
    (old: { meta = old.meta // { mainProgram = "mas"; }; });
}
