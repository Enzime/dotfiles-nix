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

  "nextcloud.age".publicKeys = builtins.attrValues {
    inherit (users) enzime;
    inherit (hosts) phi;
  };

  "x11vnc_phi.age".publicKeys = builtins.attrValues {
    inherit (users) enzime;
    inherit (hosts) phi;
  };

  "zshrc_phi.age".publicKeys = builtins.attrValues {
    inherit (users) enzime;
    inherit (hosts) phi;
  };
}
