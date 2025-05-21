{
  perSystem = { pkgs, lib, ... }: {
    treefmt = {
      programs.deadnix.enable = true;
      programs.deadnix.no-lambda-arg = true;

      programs.nixfmt-classic.enable = true;
      programs.statix.enable = true;
      programs.shellcheck.enable = true;

      settings.formatter.nil = {
        # https://github.com/cachix/git-hooks.nix/blob/fa466640195d38ec97cf0493d6d6882bc4d14969/modules/hooks.nix#L3242-L3261
        command = lib.getExe (pkgs.writeShellApplication {
          name = "nil";
          runtimeInputs = [ pkgs.nil ];
          text = ''
            errors=false
            echo "Checking: $*"
            for file in "$@"; do
              nil diagnostics "$file"
              exit_code=$?

              if [[ $exit_code -ne 0 ]]; then
                echo "\"$file\" failed with exit code: $exit_code"
                errors=true
              fi
            done
            if [[ $errors == true ]]; then
              exit 1
            fi
          '';
        });
        includes = [ "*.nix" ];
      };
    };
  };
}
