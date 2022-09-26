{
  nixosModule = { config, ... }: {
    # security.acme.defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    security.acme.defaults.email = "letsencrypt@enzim.ee";
    security.acme.defaults.group = config.services.nginx.group;
    security.acme.acceptTerms = true;
  };
}
