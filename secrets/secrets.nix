let inherit (import ../keys.nix) users hosts;
in {
  "acme_zoneee.age".publicKeys = builtins.attrValues {
    inherit (users) enzime;
    inherit (hosts) phi;
  };

  "duckdns.age".publicKeys = builtins.attrValues {
    inherit (users) enzime;
    inherit (hosts) phi;
  };

  "github-runner.age".publicKeys = builtins.attrValues {
    inherit (users) enzime;
    inherit (hosts) echo;
  };

  "nextcloud.age".publicKeys = builtins.attrValues {
    inherit (users) enzime;
    inherit (hosts) phi;
  };

  "zshrc_phi.age".publicKeys = builtins.attrValues {
    inherit (users) enzime;
    inherit (hosts) phi;
  };
}
