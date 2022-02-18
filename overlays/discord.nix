self: super: {
  discord = super.discord.overrideAttrs (old: let
    version = assert builtins.compareVersions old.version "0.0.17" == -1; "0.0.17";
  in {
    inherit version;

    src = super.fetchurl {
      url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
      sha256 = "sha256-NGJzLl1dm7dfkB98pQR3gv4vlldrII6lOMWTuioDExU=";
    };
  });
}
