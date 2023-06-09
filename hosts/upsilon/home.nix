{ keys, ... }:

{
  programs.git.extraConfig.user.signingKey = keys.users."michael.hoang_upsilon";
}
