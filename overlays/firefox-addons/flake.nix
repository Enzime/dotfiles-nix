{
  inputs.firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
  inputs.firefox-addons.inputs.nixpkgs.follows = "nixpkgs";
  inputs.firefox-addons.inputs.flake-utils.follows = "flake-utils";

  outputs = { firefox-addons, nixpkgs, flake-utils, ... }: {
    overlay = self: super: let
      pkgs = import nixpkgs { inherit (super) system; };

      addons = import "${firefox-addons}/pkgs/firefox-addons" {
        inherit (pkgs) fetchurl lib;
        stdenv = pkgs.stdenv.override { config.allowUnfree = true; };
      };
    in {
      firefox-addons = addons // (let
        inherit (builtins) hasAttr;
        inherit (addons) buildFirefoxXpiAddon;
      in {
        copy-selected-links = (assert (!hasAttr "copy-selected-links" addons); buildFirefoxXpiAddon {
          pname = "copy-selected-links";
          version = "2.4.1";
          addonId = "jid1-vs5odTmtIydjMg@jetpack";
          url = "https://addons.mozilla.org/firefox/downloads/file/3860788/copy_selected_links-2.4.1-fx.xpi";
          sha256 = "sha256-8y4qMFGN/Pcs/TntpQFchXldaUwJudKe0MYvZ+2HaOE=";
          meta = {};
        });

        hover-zoom-plus = (assert (!hasAttr "hover-zoom-plus" addons); buildFirefoxXpiAddon {
          pname = "hover-zoom-plus";
          version = "1.0.187";
          addonId = "{92e6fe1c-6e1d-44e1-8bc6-d309e59406af}";
          url = "https://addons.mozilla.org/firefox/downloads/file/3890352/hover_zoom_official-1.0.187-fx.xpi";
          sha256 = "sha256-L45hG0ReTLJfUw4mTpTiQPOUpg+jIEP/msdrtGFHemU=";
          meta = {};
        });

        redirector = (assert (!hasAttr "redirector" addons); buildFirefoxXpiAddon {
          pname = "redirector";
          version = "3.5.3";
          addonId = "redirector@einaregilsson.com";
          url = "https://addons.mozilla.org/firefox/downloads/file/3535009/redirector-3.5.3-an+fx.xpi";
          sha256 = "sha256-7dvT1ZROdI0L1uy22enPDgwC3O1vQtshqrZBkOccD3E=";
          meta = {};
        });

        tst-wheel-and-double = (assert (!hasAttr "tst-wheel-and-double" addons); buildFirefoxXpiAddon {
          pname = "tst-wheel-and-double";
          version = "1.5";
          addonId = "tst-wheel_and_double@dontpokebadgers.com";
          url = "https://addons.mozilla.org/firefox/downloads/file/3473925/tree_style_tab_mouse_wheel-1.5-fx.xpi";
          sha256 = "sha256-ybrVH86xjnMjRl/SXdgd98bLP126+Hjcb4ToljxJK7U=";
          meta = {};
        });

        web-archives = (assert (!hasAttr "web-archives" addons); buildFirefoxXpiAddon {
          pname = "web-archives";
          version = "3.1.0";
          addonId = "{d07ccf11-c0cd-4938-a265-2a4d6ad01189}";
          url = "https://addons.mozilla.org/firefox/downloads/file/3894402/web_archives-3.1.0-an+fx.xpi";
          sha256 = "sha256-uCdkebx7KszyNLsbRVuUlprN8esgWdgAIKtD6/SJSdQ=";
          meta = {};
        });

        youtube-nonstop = (assert (!hasAttr "youtube-nonstop" addons); buildFirefoxXpiAddon {
          pname = "youtube-nonstop";
          version = "0.9.1";
          addonId = "{0d7cafdd-501c-49ca-8ebb-e3341caaa55e}";
          url = "https://addons.mozilla.org/firefox/downloads/file/3848483/youtube_nonstop-0.9.1-fx.xpi";
          sha256 = "sha256-g0DVdiKmY5SewXaOs31HZRyAn63w/6pf9UbEj90o4z0=";
          meta = {};
        });
      });
    };
  };
}
