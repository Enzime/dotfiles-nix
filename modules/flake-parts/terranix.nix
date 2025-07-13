{ self-lib, self, lib, inputs, ... }: {
  options.flake.terranixModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = { };
  };

  config = {
    perSystem = { system, self', inputs', pkgs, ... }: {
      packages.tf = pkgs.opentofu.withPlugins (p:
        builtins.attrValues {
          inherit (p)
            external hcloud local null onepassword tailscale tls vultr;
        });

      packages.get-clan-secret = pkgs.writeShellApplication {
        name = "get-clan-secret";
        runtimeInputs = builtins.attrValues {
          inherit (pkgs) jq;
          inherit (inputs'.clan-core.packages) clan-cli;
        };
        text = ''
          jq -n --arg secret "$(clan secrets get "$1")" '{"secret":$secret}'
        '';
      };

      packages.tf-apply = pkgs.writeShellApplication {
        name = "tf-apply";
        runtimeInputs = [ self'.packages.tf ];
        text = let inherit (self'.packages.tf.meta) mainProgram;
        in ''
          if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
          cp ${self'.terraformConfigurations.everything} config.tf.json \
            && ${mainProgram} init \
            && ${mainProgram} apply "$@"
        '';
      };

      packages.tf-destroy = pkgs.writeShellApplication {
        name = "tf-destroy";
        runtimeInputs = [ self'.packages.tf ];
        text = let inherit (self'.packages.tf.meta) mainProgram;
        in ''
          if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
          cp ${self'.terraformConfigurations.everything} config.tf.json \
            && ${mainProgram} init \
            && ${mainProgram} destroy "$@"
        '';
      };

      terraformConfigurations.everything =
        inputs.terranix.lib.terranixConfiguration {
          inherit system;
          modules = [ self.terranixModules.everything ];
          extraArgs = { inherit self' inputs inputs'; };
        };
    };

    flake.terranixModules = {
      default = self-lib.pathTo ./modules/terranix/base.nix;
    };
  };
}
