{
  perSystem =
    {
      self',
      pkgs,
      lib,
      ...
    }:
    {
      treefmt = {
        programs.deadnix.enable = true;
        programs.deadnix.no-lambda-arg = true;

        programs.nixfmt.enable = true;
        programs.statix.enable = true;
        programs.shellcheck.enable = true;

        settings.formatter.nil = {
          # https://github.com/cachix/git-hooks.nix/blob/fa466640195d38ec97cf0493d6d6882bc4d14969/modules/hooks.nix#L3242-L3261
          command = lib.getExe (
            pkgs.writeShellApplication {
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
            }
          );
          includes = [ "*.nix" ];
        };
      };

      packages.cached-nix-fmt = pkgs.writeShellApplication {
        name = "cached-nix-fmt";
        runtimeInputs = builtins.attrValues {
          inherit (pkgs) coreutils moreutils;
          inherit (pkgs.nixVersions) latest;
        };
        text = ''
          set -x

          TOPLEVEL=$(git rev-parse --show-toplevel)
          FORMATTER_DIR="$TOPLEVEL/.formatter"
          FORMATTER_BINARY="$FORMATTER_DIR/binary"

          if [[ ! -e "$FORMATTER_BINARY" || "$(stat -c %Y "$FORMATTER_BINARY")" -lt "$(date -d "7 days ago" +%s)" ]]; then
            rm -rf "$FORMATTER_DIR"
            mkdir -p "$FORMATTER_DIR"

            echo "/*" | sponge "$FORMATTER_DIR/.gitignore"

            if nix eval .#formatter."$(nix config show system)" > /dev/null; then
              FORMATTER=$(nix formatter build --out-link "$FORMATTER_DIR/store-path")
            else
              FORMATTER="${lib.getExe self'.packages.noop-treefmt}"
            fi

            ln -sf "$FORMATTER" "$FORMATTER_BINARY"
          fi
          exec "$FORMATTER_BINARY" "$@"
        '';
      };

      packages.noop-treefmt = pkgs.writeShellApplication {
        name = "noop-treefmt";
        text = ''
          stdin=false

          for arg in "$@"; do
            if [[ "$arg" == "--stdin" ]]; then
              stdin=true
            fi
          done

          if [[ "$stdin" == "true" ]]; then
            exec cat
          fi
        '';
      };
    };
}
