self: super: {
  # From https://github.com/bromanko/nix-config/blob/92efba7b4a4c8d2d5bec61d46e7c5fca7a845ea3/modules/home-manager/shell/jujutsu.nix#L12-L19
  jujutsu = super.jujutsu.overrideAttrs (old:
    super.lib.optionalAttrs super.stdenv.hostPlatform.isDarwin {
      nativeBuildInputs = old.nativeBuildInputs ++ [ super.makeWrapper ];
      postInstall = (old.postInstall or "") + ''
        # Export via run rather than set to expand the ~ variable
        wrapProgram $out/bin/jj \
          --run "export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock"
      '';
    });
}
