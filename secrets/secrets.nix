let
  inherit (import ../keys.nix) users hosts;
in {
  "acme_zoneee.age".publicKeys = builtins.attrValues {
    inherit (users) enzime_phi;
    inherit (hosts) phi;
  };

  "duckdns.age".publicKeys = builtins.attrValues {
    inherit (users) enzime_phi;
    inherit (hosts) phi;
  };

  "etesync-dav.age".publicKeys = builtins.attrValues {
    inherit (users) enzime_phi;
    inherit (hosts) phi sigma;
  };

  "nextcloud.age".publicKeys = builtins.attrValues {
    inherit (users) enzime_phi;
    inherit (hosts) phi;
  };

  "x11vnc_phi.age".publicKeys = builtins.attrValues {
    inherit (users) enzime_phi;
    inherit (hosts) phi;
  };

  "zshrc_phi.age".publicKeys = builtins.attrValues {
    inherit (users) enzime_phi;
    inherit (hosts) phi;
  };
}
