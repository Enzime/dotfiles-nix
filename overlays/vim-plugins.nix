self: super:
let
  inherit (super) fetchFromGitHub;
  inherit (super.vimUtils) buildVimPlugin;
in {
  vimPlugins = super.vimPlugins // super.lib.mapAttrs (name: plugin:
    if super.vimPlugins ? ${name} then
      throw "vimPlugins.${name} already exists"
    else
      plugin) {
        hybrid-krompus-vim = buildVimPlugin {
          pname = "hybrid-krompus.vim";
          version = "2016-07-02";
          src = fetchFromGitHub {
            owner = "airodactyl";
            repo = "hybrid-krompus.vim";
            rev = "1b008739e0fcc04c69f0a71e222949f38bf3fada";
            hash = "sha256-ZOuuHeeZaIZVVdf1mh35Y4WaVTWVYXboG0+l/GscVUg=";
          };
          meta.homepage = "https://github.com/airodactyl/hybrid-krompus.vim";
        };

        neovim-ranger = buildVimPlugin {
          pname = "neovim-ranger";
          version = "2015-09-30";
          src = fetchFromGitHub {
            owner = "airodactyl";
            repo = "neovim-ranger";
            rev = "8726761cb7582582e60f3b1ee6498acc6d3c03a7";
            hash = "sha256-gHFO39R5/YdJ2wm5x3pjNZF30HOWLHmH/bcou920IwY=";
          };
          meta.homepage = "https://github.com/airodactyl/neovim-ranger";
        };

        vim-operator-flashy = buildVimPlugin {
          pname = "vim-operator-flashy";
          version = "2016-10-09";
          src = fetchFromGitHub {
            owner = "haya14busa";
            repo = "vim-operator-flashy";
            rev = "b24673a9b0d5d60b26d202deb13d4ebf90d7a2ae";
            hash = "sha256-CGU7wzr2SQHH0oT9S5Oj3K1XxznRNAA9qdi7QNlRW4A=";
          };
          meta.homepage = "https://github.com/haya14busa/vim-operator-flashy";
        };
      };
}
