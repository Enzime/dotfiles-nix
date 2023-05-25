{
  inputs.firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
  inputs.firefox-addons.inputs.nixpkgs.follows = "nixpkgs";
  inputs.firefox-addons.inputs.flake-utils.follows = "flake-utils";

  outputs = { firefox-addons, nixpkgs, flake-utils, ... }: {
    overlay = final: prev: let
      addons = import "${firefox-addons}/pkgs/firefox-addons" {
        inherit (prev) fetchurl lib stdenv;
      };
    in {
      firefox-addons = addons // (let
        inherit (prev.lib) mapAttrs;
        inherit (addons) buildFirefoxXpiAddon;
      in mapAttrs (name: addon:
        if addons ? ${name} then
          throw "firefox-addons.${name} already exists"
        else
          addon
        ) {
        bing-chat-for-all-browsers = buildFirefoxXpiAddon {
          pname = "bing-chat-for-all-browsers";
          version = "1.0.7";
          addonId = "{a9cb10b9-75e9-45c3-8194-d3b2c25bb6a2}";
          url = "https://addons.mozilla.org/firefox/downloads/file/4099909/bing_chat_for_all_browsers-1.0.7.xpi";
          sha256 = "sha256-IIvZLtSnUzm4wqDNdnpHtIWTNy1SwQDAkv8N1RgCVFs=";
          meta = {};
        };

        copy-selected-links = buildFirefoxXpiAddon {
          pname = "copy-selected-links";
          version = "2.4.1";
          addonId = "jid1-vs5odTmtIydjMg@jetpack";
          url = "https://addons.mozilla.org/firefox/downloads/file/3860788/copy_selected_links-2.4.1-fx.xpi";
          sha256 = "sha256-8y4qMFGN/Pcs/TntpQFchXldaUwJudKe0MYvZ+2HaOE=";
          meta = {};
        };

        hover-zoom-plus = buildFirefoxXpiAddon {
          pname = "hover-zoom-plus";
          version = "1.0.205";
          addonId = "{92e6fe1c-6e1d-44e1-8bc6-d309e59406af}";
          url = "https://addons.mozilla.org/firefox/downloads/file/4098518/hover_zoom_plus-1.0.205.xpi";
          sha256 = "sha256-DoyE51Yry+F4T4pWnluargjDypxp44ZlFqyZhpbCfLs=";
          meta = {};
        };

        improve-youtube = buildFirefoxXpiAddon {
          pname = "improve-youtube";
          version = "3.935";
          addonId = "{3c6bf0cc-3ae2-42fb-9993-0d33104fdcaf}";
          url = "https://addons.mozilla.org/firefox/downloads/file/3896635/improve_youtube_open_source_for_youtube-3.935-an+fx.xpi";
          sha256 = "sha256-nWi21FB+KoqgsrH29I+RWR0v+B6hjncwIbHR2pWRnqc=";
          meta = {};
        };

        open-url-in-container = buildFirefoxXpiAddon {
          pname = "open-url-in-container";
          version = "1.0.3";
          addonId = "{f069aec0-43c5-4bbf-b6b4-df95c4326b98}";
          url = "https://addons.mozilla.org/firefox/downloads/file/3566167/open_url_in_container-1.0.3.xpi";
          sha256 = "sha256-aHIRpf5u4IwrMGApKFhHSyf5E4Mpa8G2ugORwAq8Jpc=";
          meta = {};
        };

        tetrio-plus = buildFirefoxXpiAddon {
          pname = "tetrio-plus";
          version = "0.23.7";
          addonId = "tetrio-plus@example.com";
          url = "https://addons.mozilla.org/firefox/downloads/file/3885942/tetrio_plus-0.23.7-an+fx.xpi";
          sha256 = "sha256-ZwrdT76yaeWyh9LFMgwtcworln4CWWx4Kp8jHtzb3dY=";
          meta = {};
        };

        tst-wheel-and-double = buildFirefoxXpiAddon {
          pname = "tst-wheel-and-double";
          version = "1.5";
          addonId = "tst-wheel_and_double@dontpokebadgers.com";
          url = "https://addons.mozilla.org/firefox/downloads/file/3473925/tree_style_tab_mouse_wheel-1.5-fx.xpi";
          sha256 = "sha256-ybrVH86xjnMjRl/SXdgd98bLP126+Hjcb4ToljxJK7U=";
          meta = {};
        };

        web-archives = buildFirefoxXpiAddon {
          pname = "web-archives";
          version = "4.0.0";
          addonId = "{d07ccf11-c0cd-4938-a265-2a4d6ad01189}";
          url = "https://addons.mozilla.org/firefox/downloads/file/4065318/view_page_archive-4.0.0.xpi";
          sha256 = "sha256-Pg4KfXVxNZdeCT4jOfdQzop2K+R8gCxZZ5oJlJMe00Y=";
          meta = {};
        };

        youtube-nonstop = buildFirefoxXpiAddon {
          pname = "youtube-nonstop";
          version = "0.9.1";
          addonId = "{0d7cafdd-501c-49ca-8ebb-e3341caaa55e}";
          url = "https://addons.mozilla.org/firefox/downloads/file/3848483/youtube_nonstop-0.9.1-fx.xpi";
          sha256 = "sha256-g0DVdiKmY5SewXaOs31HZRyAn63w/6pf9UbEj90o4z0=";
          meta = {};
        };
      });
    };
  };
}
