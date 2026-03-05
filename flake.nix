{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.nix-darwin.url = "github:nix-darwin/nix-darwin/pull/1701/merge";
  inputs.nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.systems.url = "github:nix-systems/default";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.systems.follows = "systems";
  inputs.flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
  inputs.flake-utils-plus.inputs.flake-utils.follows = "flake-utils";

  inputs.firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
  inputs.firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

  inputs.terranix.url = "github:terranix/terranix";
  inputs.terranix.inputs.flake-parts.follows = "flake-parts";
  inputs.terranix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.terranix.inputs.systems.follows = "systems";

  inputs.nixos-anywhere.url = "github:nix-community/nixos-anywhere";
  inputs.nixos-anywhere.inputs.disko.follows = "disko";
  inputs.nixos-anywhere.inputs.flake-parts.follows = "flake-parts";
  inputs.nixos-anywhere.inputs.nixos-stable.follows = "";
  inputs.nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-anywhere.inputs.treefmt-nix.follows = "";

  inputs.preservation.url = "github:nix-community/preservation";

  inputs.nix-index-database.url = "github:nix-community/nix-index-database";
  inputs.nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

  inputs.clan-core.url = "git+https://git.clan.lol/clan/clan-core?shallow=1";
  inputs.clan-core.inputs.disko.follows = "disko";
  inputs.clan-core.inputs.flake-parts.follows = "flake-parts";
  inputs.clan-core.inputs.nixpkgs.follows = "nixpkgs";
  inputs.clan-core.inputs.nix-darwin.follows = "nix-darwin";
  inputs.clan-core.inputs.systems.follows = "systems";
  # This causes a stack overflow when set to empty string or relative path inputs
  inputs.clan-core.inputs.treefmt-nix.follows = "systems";

  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.hoopsnake.url = "github:boinkor-net/hoopsnake";
  inputs.hoopsnake.inputs.flake-parts.follows = "flake-parts";
  inputs.hoopsnake.inputs.devshell.follows = "";
  inputs.hoopsnake.inputs.generate-go-sri.follows = "";
  inputs.hoopsnake.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nixpkgs-terraform-providers-bin.url = "github:nix-community/nixpkgs-terraform-providers-bin";
  inputs.nixpkgs-terraform-providers-bin.inputs.nixpkgs.follows = "nixpkgs";

  inputs.llm-agents.url = "github:numtide/llm-agents.nix";
  inputs.llm-agents.inputs.nixpkgs.follows = "nixpkgs";
  inputs.llm-agents.inputs.blueprint.inputs.systems.follows = "systems";
  inputs.llm-agents.inputs.treefmt-nix.follows = "treefmt-nix";

  inputs.claude-code-sandbox.url = "github:neko-kai/claude-code-sandbox";
  inputs.claude-code-sandbox.inputs.nixpkgs.follows = "nixpkgs";
  inputs.claude-code-sandbox.inputs.flake-utils.follows = "flake-utils";

  inputs.neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  inputs.neovim-nightly-overlay.inputs.flake-parts.follows = "flake-parts";
  inputs.neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs = {
          self-lib = (import ./lib.nix) { inherit (inputs.nixpkgs) lib; };
        };
      }
      {
        imports = [
          inputs.clan-core.flakeModules.default
          inputs.treefmt-nix.flakeModule

          ./hosts/flake-module.nix
          ./modules/flake-parts/flake-module.nix
          ./.github/flake-module.nix
        ];
        systems = import inputs.systems;

        # Dirty hack to enable debug mode in `nix repl`
        debug = builtins ? currentSystem;
      };
}
