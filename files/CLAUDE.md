## General Guidelines

- Follow XDG desktop standards
- Regularly reason about security implications of the code
- Use `~/Code/claude/:scratch` as a scratch directory.
- In the Bash tool use absolute paths over `cd`

## Nix-specific

- Use `--log-format bar-with-logs` with Nix for improved build log output.
- Use `nix run` or `nix shell <installable> -c` to use programs that might not be installed.
- Use `nix eval` instead of `nix flake show` to look up attributes in a flake.
- Do not use `nix flake check` on the whole flake; it is too slow. Instead,
  build individual tests.

## Code Quality & Testing

- Format code with `nix fmt .` if the current project has a flake with a
  formatter defined.
- Write shell scripts that pass `shellcheck`.
- Write Python code for 3.13 that conforms to `ruff format`, `ruff check` and
  `mypy`
- Add debug output or unit tests when troubleshooting i.e. dbg!() in Rust
- When writing test use realistic inputs/outputs that test the actual code as
  opposed to mocked out versions
- IMPORTANT: GOOD: When given a linter error, address the root cause of the
  linting error. BAD: silencing lint errors. Exhaustivly fix all linter errors.

## Git

- When writing commit messages/comments focus on the WHY rather than the WHAT.
- Always test/lint/format your code before committing.
- Use `gfc` to full clone repositories and do it inside `$HOME/Code/claude`
- Use `gsc` instead of `gfc` to shallow clone repositories
- Always use `ghro:org/repo` when cloning GitHub repos
- Rename the remote to `upstream` after cloning before running Jujutsu
- Try to always use `jj` instead of `git`
- Use the gh tool to interact with GitHub i.e.: `gh run view 18256703410 --log`

## Jujutsu

- Instead of stashing Git changes, you can just switch to a new Jujutsu change
- Always run `jj git init` after cloning a Git repo so that it has Jujutsu support
- Configure Jujutsu to use the new remote name only by setting `git.fetch`
- Don't enable automatic local bookmark creation in Jujutsu
- Avoid using interactive commands like `jj describe`, `jj split` and `jj squash` without `-m`
- Don't abandon empty working copy commits they'll just get recreated, just move somewhere else like the end of a branch using `jj new`

## Search

- Recommended: Use GitHub code search to find examples for libraries and APIs:
  `gh search code "foo lang:nix"`.
- Prefer cloning source code over web searches for more accurate results.
  Various projects are available in `$HOME/Code`, including:
- `$HOME/Code/nixpkgs`
- `$HOME/Work/clan/clan-core`
