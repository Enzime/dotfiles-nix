let
  inherit (import ../keys.nix) users hosts;
in {
  "acme_zoneee.age".publicKeys = builtins.attrValues {
    inherit (users) enzime_phi;
    inherit (hosts) phi;
  };

  "aws_config.age".publicKeys = builtins.attrValues {
    inherit (users) "michael.hoang_upsilon";
    inherit (hosts) upsilon;
  };

  "duckdns.age".publicKeys = builtins.attrValues {
    inherit (users) enzime_phi;
    inherit (hosts) phi;
  };

  "git_config.age".publicKeys = builtins.attrValues {
    inherit (users) "michael.hoang_upsilon";
    inherit (hosts) upsilon;
  };

  "nextcloud.age".publicKeys = builtins.attrValues {
    inherit (users) enzime_phi;
    inherit (hosts) phi;
  };

  "npmrc.age".publicKeys = builtins.attrValues {
    inherit (users) "michael.hoang_upsilon";
    inherit (hosts) upsilon;
  };

  "ssh_allowed_signers.age".publicKeys = builtins.attrValues {
    inherit (users) "michael.hoang_upsilon";
    inherit (hosts) upsilon;
  };

  "x11vnc_phi.age".publicKeys = builtins.attrValues {
    inherit (users) enzime_phi;
    inherit (hosts) phi;
  };

  "zshrc_phi.age".publicKeys = builtins.attrValues {
    inherit (users) enzime_phi;
    inherit (hosts) phi;
  };

  "zshrc_upsilon.age".publicKeys = builtins.attrValues {
    inherit (users) "michael.hoang_upsilon";
    inherit (hosts) upsilon;
  };
}
