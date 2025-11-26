{
  nixosModule = { options, config, pkgs, lib, ... }: {
    imports = [
      {
        config = lib.optionalAttrs (options ? clan) {
          clan.core.vars.generators.acme-desec = {
            share = true;
            prompts.token.persist = true;
          };
        };
      }
      {
        # WORKAROUND: `security.acme.defaults.dnsProvider` isn't properly propagated
        # https://github.com/NixOS/nixpkgs/issues/210807
        options.services.nginx.virtualHosts = lib.mkOption {
          type = lib.types.attrsOf
            (lib.types.submodule { config.acmeRoot = lib.mkDefault null; });
        };
      }
    ];

    # security.acme.defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    security.acme.defaults.email = "letsencrypt@enzim.ee";
    security.acme.defaults.group = config.services.nginx.group;
    security.acme.acceptTerms = true;

    security.acme.defaults = {
      dnsProvider = "desec";
      # WORKAROUND: propagation takes a really long time with deSEC
      # https://talk.desec.io/t/global-record-propagation-issues/332
      environmentFile = pkgs.writeText "acme-environment" ''
        DESEC_PROPAGATION_TIMEOUT=300
      '';
      credentialFiles = {
        DESEC_TOKEN_FILE =
          config.clan.core.vars.generators.acme-desec.files.token.path;
      };
    };

    preservation.preserveAt."/persist".directories = [ "/var/lib/acme" ];
  };
}
