{ self, ... }: {
  perSystem = { system, pkgs, lib, ... }: {
    packages = let
      vmWithNewHostPlatform = name:
        pkgs.writeShellApplication {
          name = "run-${name}-vm-on-${system}";
          runtimeInputs = builtins.attrValues { inherit (pkgs) jq; };
          text = ''
            set -x

            drv="$(nix eval --raw ${self}#nixosConfigurations.${name} \
              --apply 'original:
                let configuration = original.extendModules { modules = [ ({ lib, ... }: {
                  _file = "<nixos-rebuild build-vm override>";
                  nixpkgs.hostPlatform = lib.mkForce "${system}";
                }) ]; };
                in configuration.config.system.build.vm.drvPath' )"
            vm=$(nix build --no-link "$drv^*" --json | jq -r '.[0].outputs.out')
            # shellcheck disable=SC2211
            "$vm"/bin/run-*-vm
          '';
        };
    in lib.mapAttrs' (hostname: configuration:
      lib.nameValuePair "${hostname}-vm" (vmWithNewHostPlatform hostname))
    self.nixosConfigurations;
  };
}
