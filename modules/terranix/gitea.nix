{
  config,
  ...
}:

{
  terraform.required_providers.gitea.source = "go-gitea/gitea";

  data.onepassword_item.gitea-admin = {
    vault = "vs2dd6mjcdqs3wgd3l4eubfg54";
    uuid = "yu6xdfsscvr726ypais236qy6m";
  };

  resource.onepassword_item.gitea-hyperbot = {
    vault = "r3fgka56ukyvdslqp3jxc37e3q";
    title = "Clan";
    category = "login";
    username = "hyperbot";
    url = "https://git.clan.lol";
    password_recipe = {
      length = 32;
    };
  };

  provider.gitea = [
    {
      base_url = "https://git.clan.lol";
      username = config.data.onepassword_item.gitea-admin "username";
      password = config.data.onepassword_item.gitea-admin "password";
    }
    {
      alias = "hyperbot";
      base_url = "https://git.clan.lol";
      username = "hyperbot";
      password = config.resource.onepassword_item.gitea-hyperbot "password";
    }
  ];

  resource.gitea_user.hyperbot = {
    username = "hyperbot";
    login_name = "hyperbot";
    email = "hyperbot@enzim.ee";
    password = config.resource.onepassword_item.gitea-hyperbot "password";
    visibility = "private";
    must_change_password = false;
    send_notification = false;
    allow_create_organization = false;
    allow_git_hook = false;
    allow_import_local = false;
  };

  resource.gitea_token.hyperbot = {
    provider = "gitea.hyperbot";
    name = "terraform";
    scopes = [ "all" ];
    depends_on = [ "gitea_user.hyperbot" ];
  };

  data.onepassword_item.github-ro = {
    vault = "r3fgka56ukyvdslqp3jxc37e3q";
    title = "GitHub readonly PAT";
  };

  resource.gitea_repository_actions_secret.hyperbot-gitea-token = {
    repository_owner = "enzime";
    repository = "hyperconfig";
    secret_name = "HYPERBOT_GITEA_TOKEN";
    secret_value = config.resource.gitea_token.hyperbot "token";
  };

  resource.gitea_repository_actions_secret.hyperbot-github-token = {
    repository_owner = "enzime";
    repository = "hyperconfig";
    secret_name = "HYPERBOT_GITHUB_TOKEN";
    secret_value = config.data.onepassword_item.github-ro "credential";
  };
}
