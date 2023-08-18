self: super: {
  powermenu =
    super.writeScriptBin "powermenu" (builtins.readFile ../files/powermenu);
}
