{
  perSystem = { self', inputs', pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      buildInputs = builtins.attrValues {
        inherit (inputs'.home-manager.packages) home-manager;
        inherit (inputs'.clan-core.packages) clan-cli;
        inherit (self'.packages) tf;
      };

      shellHook = ''
        POST_CHECKOUT_HOOK=$(git rev-parse --git-common-dir)/hooks/post-checkout
        TMPFILE=$(mktemp)
        if curl -o $TMPFILE --fail https://raw.githubusercontent.com/Enzime/dotfiles-nix/HEAD/files/post-checkout; then
          if [[ -e $POST_CHECKOUT_HOOK ]]; then
            echo "Removing existing $POST_CHECKOUT_HOOK"
            rm $POST_CHECKOUT_HOOK
          fi
          echo "Replacing $POST_CHECKOUT_HOOK with $TMPFILE"
          cp $TMPFILE $POST_CHECKOUT_HOOK
          chmod a+x $POST_CHECKOUT_HOOK
        fi

        if [[ -e $POST_CHECKOUT_HOOK ]]; then
          $POST_CHECKOUT_HOOK
        fi
      '';
    };
  };
}
