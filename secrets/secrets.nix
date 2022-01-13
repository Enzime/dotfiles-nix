let
  inherit (import ../keys.nix) users hosts;
in {
  "aws_config.age".publicKeys = builtins.attrValues {
    inherit (users) enzime_tau;
    inherit (hosts) tau;
  };

  "duckdns.age".publicKeys = builtins.attrValues {
    inherit (users) enzime_phi;
    inherit (hosts) phi;
  };

  "zshrc_phi.age".publicKeys = builtins.attrValues {
    inherit (users) enzime_phi;
    inherit (hosts) phi;
  };

  "zshrc_tau.age".publicKeys = builtins.attrValues {
    inherit (users) enzime_tau;
    inherit (hosts) tau;
  };
}
