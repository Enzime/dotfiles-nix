{
  nixosModule = { modulesPath, pkgs, lib, ... }: {
    imports = [ (modulesPath + "/profiles/perlless.nix") ];

    system.forbiddenDependenciesRegexes = lib.mkForce [ ];

    systemd.services.userborn.before =
      assert lib.versionOlder pkgs.systemd.version "258";
      [ "systemd-oomd.socket" ];
  };
}
