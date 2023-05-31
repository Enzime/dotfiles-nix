{ keys, ... }:

{
  programs.git.extraConfig = {
    user.signingKey = keys.users."michael.hoang_upsilon";
    gpg.format = "ssh";
    gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
  };
}
