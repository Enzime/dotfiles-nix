{
  nixosModule = { modulesPath, lib, ... }: {
    imports = [ (modulesPath + "/profiles/perlless.nix") ];

    system.forbiddenDependenciesRegexes = lib.mkForce [ ];

    image.modules.iso-installer = {
      disabledModules = [ (modulesPath + "/profiles/perlless.nix") ];
    };
  };
}
