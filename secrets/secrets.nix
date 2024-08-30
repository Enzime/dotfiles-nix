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

  "password-hash_enzime-sigma.age".publicKeys = builtins.attrValues {
    inherit (users) enzime;
    inherit (hosts) sigma;
  };

  "wireless.age".publicKeys = builtins.attrValues {
    inherit (users) enzime;
    inherit (hosts) hermes-nixos phi sigma;
  };

  "zshrc_phi.age".publicKeys = builtins.attrValues {
    inherit (users) enzime;
    inherit (hosts) phi;
  };
}
