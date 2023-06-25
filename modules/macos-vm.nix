{
  nixosModule = { inputs, pkgs, lib, modulesPath, ... }: {
    imports = [ (modulesPath + "/virtualisation/qemu-vm.nix") ];

    virtualisation.memorySize = 3 * 1024;

    virtualisation.host.pkgs = import inputs.nixpkgs {
      system = builtins.replaceStrings [ "linux" ] [ "darwin" ] pkgs.system;
      inherit (pkgs) config overlays;
    };

    services.xserver.displayManager.defaultSession = lib.mkForce "none+i3";
    environment.variables.LIBGL_ALWAYS_SOFTWARE = "true";
  };
}
