{
  darwinModule = { config, host, pkgs, ... }: {
    age.secrets.github-runner.file = ../secrets/github-runner.age;
    age.secrets.github-runner.owner =
      config.launchd.daemons.github-runner-runner.serviceConfig.UserName;

    services.github-runners.runner = {
      enable = true;
      name = host;
      url = "https://github.com/Enzime/dotfiles-nix";
      tokenFile = config.age.secrets.github-runner.path;
      extraPackages = builtins.attrValues { inherit (pkgs) cachix; };
    };
  };
}
