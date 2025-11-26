{ self, inputs, lib, ... }: {
  options.flake.terranixModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = { };
  };

  config = {
    perSystem = { system, self', inputs', pkgs, lib, ... }: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ (import ../../overlays/terraform.nix) ];
      };

      packages.tf = pkgs.opentofu.withPlugins (p:
        builtins.attrValues {
          inherit (p)
            valodim_desec hashicorp_external hetznercloud_hcloud hashicorp_local
            hashicorp_null tailscale_tailscale hashicorp_tls vultr_vultr;

          inherit (inputs'.nixpkgs-terraform-providers-bin.legacyPackages.providers.Backblaze)
            b2;
        });

      packages.tg = pkgs.writeShellApplication {
        name = "tg";
        text = ''
          AWS_ACCESS_KEY_ID=$(clan secrets get b2-key-id)
          AWS_SECRET_ACCESS_KEY=$(clan secrets get b2-application-key)
          AWS_REQUEST_CHECKSUM_CALCULATION=when_required
          AWS_RESPONSE_CHECKSUM_VALIDATION=when_required
          TG_BACKEND_BOOTSTRAP=true
          export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
          export AWS_REQUEST_CHECKSUM_CALCULATION AWS_RESPONSE_CHECKSUM_VALIDATION
          export TG_BACKEND_BOOTSTRAP

          exec ${lib.getExe pkgs.terragrunt} "$@"
        '';
      };

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

      packages.provide-tf-passphrase = pkgs.writeShellApplication {
        name = "opentofu-external-key-provider";
        runtimeInputs = builtins.attrValues {
          inherit (pkgs) jq;
          inherit (inputs'.clan-core.packages) clan-cli;
        };
        text = ''
          # Output the header as a single line
          echo '{"magic":"OpenTofu-External-Key-Provider","version":1}'

          # Read the input metadata
          INPUT=$(cat)

          PASSPHRASE=$(clan secrets get tf-passphrase)

          if [[ "$INPUT" == "null" ]]; then
            # We don't have metadata and shouldn't output a decryption key.
            jq -n --arg key "$PASSPHRASE" '{"keys":{"encryption_key":($key|@base64)}}'
          else
            # We have metadata and should output a decryption key. In our simplified case
            # it is the same as the encryption key.
            jq -n --arg key "$PASSPHRASE" '{"keys":{"encryption_key":($key|@base64),"decryption_key":($key|@base64)}}'
          fi
        '';
      };

      packages.tf-init = pkgs.writeShellApplication {
        name = "tf-init";
        runtimeInputs = [ self'.packages.tf self'.packages.tg ];
        text = let inherit (self'.packages.tg.meta) mainProgram;
        in ''
          if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
          if [[ -e terragrunt.hcl.json ]]; then rm -f terragrunt.hcl.json; fi
          cp ${self'.terraformConfigurations.everything} config.tf.json
          cp ${self'.terraformConfigurations.terragrunt} terragrunt.hcl.json
          ${mainProgram} init "$@"
        '';
      };

      packages.tf-apply = pkgs.writeShellApplication {
        name = "tf-apply";
        runtimeInputs = [ self'.packages.tf self'.packages.tg ];
        text = let inherit (self'.packages.tg.meta) mainProgram;
        in ''
          if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
          if [[ -e terragrunt.hcl.json ]]; then rm -f terragrunt.hcl.json; fi
          cp ${self'.terraformConfigurations.everything} config.tf.json
          cp ${self'.terraformConfigurations.terragrunt} terragrunt.hcl.json
          ${mainProgram} apply "$@"
        '';
      };

      packages.tf-destroy = pkgs.writeShellApplication {
        name = "tf-destroy";
        runtimeInputs = [ self'.packages.tf self'.packages.tg ];
        text = let inherit (self'.packages.tg.meta) mainProgram;
        in ''
          if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
          if [[ -e terragrunt.hcl.json ]]; then rm -f terragrunt.hcl.json; fi
          cp ${self'.terraformConfigurations.everything} config.tf.json
          cp ${self'.terraformConfigurations.terragrunt} terragrunt.hcl.json
          ${mainProgram} destroy "$@"
        '';
      };

      terraformConfigurations.everything =
        inputs.terranix.lib.terranixConfiguration {
          inherit system;
          modules = [ self.terranixModules.everything ];
          extraArgs = { inherit self' inputs inputs'; };
        };

      terraformConfigurations.terragrunt =
        (pkgs.formats.json { }).generate "terragrunt.hcl.json" {
          remote_state = {
            backend = "s3";
            config =
              self'.terraformConfigurations.everything.config.terraform.backend.s3;
          };
        };
    };

    flake.terranixModules = {
      backblaze = ../terranix/backblaze.nix;
      base = ../terranix/base.nix;
      dns = ../terranix/dns.nix;
      tailscale = ../terranix/tailscale.nix;

      everything.imports = [
        self.terranixModules.backblaze
        self.terranixModules.base
        self.terranixModules.dns
      ];
    };
  };
}
