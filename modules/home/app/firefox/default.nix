{
  lib,
  mylib,
  config,
  pkgs,
  inputs,
  mypkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (mylib) mkBoolOpt;
  cfg = config.nazarick.app.firefox;
  # https://github.com/gvolpe/nix-config/blob/6feb7e4f47e74a8e3befd2efb423d9232f522ccd/home/programs/browsers/firefox.nix
  custom-addons = pkgs.callPackage ./addons.nix {
    inherit (inputs.firefox-addons.lib.${pkgs.system}) buildFirefoxXpiAddon;
  };

  firefox-potatofox = pkgs.fetchFromGitea {
    domain = "codeberg.org";
    owner = "awwpotato";
    repo = "potatofox";
    rev = "6df7c2d4375520f2738eb1b4381a657b66d22da2";
    hash = "sha256-Y+WRgb6raPZTMF35obMUP9iPdLk55Ur70QQ0zHfOuDE=";
  };

  catppuccinTridactyl = pkgs.fetchFromGitHub {
    owner = "lonepie";
    repo = "catppuccin-tridactyl";
    rev = "a77c65f7ab5946b37361ae935d2192a9a714f960";
    hash = "sha256-LjLMq7vUwDdxgpdP9ClRae+gN11IPc+XMsx8/+bwUy4=";
  };

  extensions =
    (with inputs.firefox-addons.packages.${pkgs.system}; [
      # UI and functionality extensions
      sidebery
      userchrome-toggle-extended
      tridactyl
      adaptive-tab-bar-colour # *needed* if using letterboxing
      no-pdf-download

      # NOTE: probably fingerprintable, but I like good looking websites
      stylus
      darkreader

      # Github
      lovely-forks # Shows forks on github projects
      refined-github
      catppuccin-gh-file-explorer

      keepassxc-browser

      # website "privacy" and tweaks
      dearrow
      jump-cutter
      redirector
      sponsorblock
      libredirect
      remove-youtube-s-suggestions # removes a bunch from youtube which is nice

      # Privacy ones
      ublock-origin # extremely good. Don't need noscript or other blocking extensions because of this
      localcdn # discouraged on arkenfox github. I just don't think it'll hurt here
      smart-referer # certain websites need this, so get ready to blacklist them. (similar about:config setting)
      foxyproxy-standard # proxy through VPN for most things

      # creates a new container for each new website. arkenfox somewhat discourages this because they're "unnecessary" with their settings.
      # I am not clearing cookies on close, so I really like this middle ground. I could whitelist a bunch of stuff, but in
      # personal containers I'm not too worried about being tracked because I'm logged into a lot.
      temporary-containers

      terms-of-service-didnt-read
      yomitan
    ])
    ++ (with custom-addons; [
      better-canvas
      better-history-ng
    ]);
in
{
  options.nazarick.app.firefox = {
    enable = mkEnableOption "Firefox";
    userCss = mkBoolOpt true "Use custom UserCSS";
  };

  config = mkIf cfg.enable {

    xdg.configFile."tridactyl/tridactylrc" = {
      enable = true;
      source = ./tridactylrc;
    };

    xdg.configFile."tridactyl/themes/catppuccin.css" = {
      enable = true;
      source = "${catppuccinTridactyl}/catppuccin.css";
    };

    programs.firefox = {
      enable = true;
      # https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265/7
      package = pkgs.firefox;
      nativeMessagingHosts = with pkgs; [
        kdePackages.plasma-browser-integration
        tridactyl-native
        keepassxc
      ];

      policies = {
        # We live in a DRM world :(
        EncryptedMediaExtensions = {
          Enabled = true;
          Locked = true;
        };

        UserMessaging = {
          SkipOnboarding = true;
          Locked = true;
        };

        ExtensionSettings = lib.mkMerge [
          {
            "*" = {
              "blocked_install_message" = "Extensions are handled by Nix!";
              "installation_mode" = "blocked";
            };
          }
          (builtins.listToAttrs (
            lib.forEach extensions (ext: {
              name = ext.addonId;
              value = {
                installation_mode = "force_installed";
                install_url = "file://${ext}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/${ext.addonId}.xpi";
              };
            })
          ))
        ];

        Certifications = {
          # InstallEnterpriseRoots does not work on linux
          "Install" = [ "${mylib.mkCA pkgs}/rootCA.pem" ];
        };

        DisablePocket = true;
        DisableTelemetry = true;
        DisableFeedbackCommands = true;
      };

      arkenfox = {
        enable = true;
        version = "master";
      };

      profiles = {
        main = {
          id = 0;
          name = "main";
          isDefault = true;
          userChrome = mkIf cfg.userCss ''
            @import "${firefox-potatofox}/chrome/userChrome.css";
          '';

          search = {
            force = true;
            default = "kagi";
            engines = {
              "kagi" = {
                definedAliases = [ "@k" ];
                urls = [
                  {
                    template = "https://kagi.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
              };
              "SearXNG" = {
                definedAliases = [ "@sx" ];
                urls = [
                  {
                    template = "https://etsi.me/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
              };
            };
          };

          # extensions = extensions;

          arkenfox = {
            enable = true;

            "0000".enable = true;
            # STARTUP
            "0100" = {
              enable = true;
              # Start page: resume last session
              "0102"."browser.startup.page".value = 3;
              # home page = new tab page
              "0103"."browser.startup.homepage".value = "about:home";
              # New tab page = home page
              "0104"."browser.newtabpage.enabled".value = true;
            };
            # GEOLOCATION
            "0200".enable = true;
            # QUIETER FOX
            "0300" = {
              enable = true;
              # NOTE: captive portal detection is off here, use another browser
            };
            # SAFEBROWSING
            "0400" = {
              # This automatically disables SB for downloads
              enable = true;
            };
            # BLOCK IMPLICIT OUTBOUND
            "0600" = {
              enable = true;
              # no hyperlink auditing
              "0610"."browser.send_pings".enable = true; # value = false
            };
            # DNS / DoH / PROXY / SOCKS
            "0700" = {
              enable = true;
              # NOTE: this is kind of sketch depending on what you're using it for
              # I use dnscrypt-proxy2 and mainly worry about connected to websites
              # finding things
              "0702"."network.proxy.socks_remote_dns".value = false;
              "0710"."network.trr.mode".enable = true; # TRR only
              # dnscrypt-proxy2
              "0712"."network.trr.uri" = {
                enable = true;
                value = "https://127.0.0.1:3000/dns-query";
              };
              "0712"."network.trr.custom_uri" = {
                enable = true;
                value = "https://127.0.0.1:3000/dns-query";
              };
            };
            # LOCATION BAR / SEARCH BAR / SUGGESTIONS / HISTORY / FORMS
            "0800" = {
              enable = true;
              # TODO: do I want this?
              "0802"."browser.urlbar.quicksuggest.enabled".value = true;
              "0807"."browser.urlbar.clipboard.featureGate".enable = true; # value = false
              # I like keeping my history, so that's why I disable this
              "0820"."layout.css.visited_links_enabled".enable = true; # value = false
            };
            # PASSWORDS
            "0900" = {
              enable = true;
            };
            # DISK AVOIDANCE
            "1000" = {
              enable = true;
              # Don't really know if this helps anything, but doesn't hurt
              # I also have FDE
              "1001"."browser.cache.disk.enable".value = true;
              # Keep cookies everywhere (I like not having to relog in everywhere)
              "1003"."browser.sessionstore.privacy_level".value = 0;
            };
            # HTTPS
            "1200" = {
              enable = true;
              # Have some issues with it being blocked in proxies
              "1212"."security.OCSP.require".value = false;
            };
            # REFERERS
            "1600".enable = true;
            # CONTAINERS
            "1700".enable = true;
            # PLUGINS / MEDIA / WEBRTC
            # Will have some breakage on video conference sites, but again, use another temp browser
            "2000".enable = true;
            # DOM
            "2400".enable = true;
            # MISCELLANEOUS
            "2600" = {
              enable = true;
              # TODO: I don't think these affect me
              # "2603"."browser.download.start_downloads_in_tmp_dir".value = false;
              # "2603"."browser.helperApps.deleteTempFileOnExit".value = false;

              "2654"."browser.download.always_ask_before_handling_new_types".value = false;

              # Extensions are managed by system, so they can be wherever
              "2660"."extensions.enabledScopes" = {
                enable = true;
                value = 31;
              };
              "2660"."extensions.autoDisableScopes" = {
                enable = true;
                value = 0;
              };
              # I like the new extension popups
              "2661"."extensions.postDownloadThirdPartyPrompt".value = true;
              "2662"."extensions.webextensions.restrictedDomains" = {
                enable = true;
                value = lib.concatStringsSep "," [
                  "accounts-static.cdn.mozilla.net"
                  "accounts.firefox.com"
                  "addons.cdn.mozilla.net"
                  # "addons.mozilla.org" # extensions can't even do anything here
                  "api.accounts.firefox.com"
                  "content.cdn.mozilla.net"
                  "discovery.addons.mozilla.org"
                  "install.mozilla.org"
                  "oauth.accounts.firefox.com"
                  "profile.accounts.firefox.com"
                  # "support.mozilla.org" # I don't think anything is going to try to mess up the support page
                  "sync.services.mozilla.com"
                ];
              };
            };
            # ETP
            "2700".enable = true;
            # SHUTDOWN & SANITIZING
            # I want to keep everything on shut down, I don't want an ephemeral browser
            "2800".enable = false;
            # "FPP"
            "4000" = {
              enable = true;
              "4001"."privacy.fingerprintingProtection.pbmode".enable = true;
            };
            # OPTIONAL RFP
            "4500" = {
              enable = true;
              "4501"."privacy.resistFingerprinting".enable = true;
              "4501"."privacy.resistFingerprinting.pbmode".enable = true;
              # TODO: Large screen, do I need this, enabling it would be good for privacy,
              # but not for looks.
              "4502"."privacy.window.maxInnerWidth".enable = false;
              "4502"."privacy.window.maxInnerHeight".enable = false;
              # Tho keep letterboxing
              "4504"."privacy.resistFingerprinting.letterboxing".enable = true;
              "4506"."privacy.spoof_english".value = 2; # enabled
              "4520"."webgl.disabled".enable = true;
            };
            # Disk avoidance, application data isolation, eyeballs
            "5000" = {
              enable = true;
              "5003"."signon.rememberSignons" = {
                enable = true;
                value = false;
              };
              "5017"."extensions.formautofill.addresses.enabled".enable = true; # value = false
              "5017"."extensions.formautofill.creditCards.enabled".enable = true; # value = false
              # Make search explicit
              "5021"."keyword.enabled".enable = true; # value = false
            };
            # OPTIONAL HARDENING
            "5500".enable = false;
            # DON'T TOUCH
            "6000".enable = true;
            # DON'T BOTHER
            "7000".enable = false;
            # DON'T BOTHER
            "8000".enable = false;
            # NON_PROJECT RELATED
            "9000".enable = false;
          };

          settings = {
            # dnscrypt-proxy2 baybee so encrypted client hello wworks
            "network.dns.echconfig.enabled" = true;
            "network.dns.use_https_rr_as_altsvc" = true;

            # ui
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            # potato
            "uc.tweak.translucency" = true;
            "uc.tweak.sidebar.wide" = true;
            "uc.tweak.urlbar.not-floating" = true;
            "uc.tweak.no-custom-icons" = true;

            "browser.uidensity" = 1;

            "browser.uiCustomization.state" = ((mylib.miniJSON pkgs) ./ui_state.json); # This has to be mini or it won't read it

            # Good-bye weather
            "browser.newtabpage.activity-stream.feeds.weatherfeed" = false;
            "browser.newtabpage.activity-stream.showWeather" = false;
            "browser.newtabpage.activity-stream.system.showWeather" = false;
            "browser.newtabpage.activity-stream.weather.locationSearchEnabled" = false;

            # Memory management
            "browser.low_commit_space_threshold_percent" = 30; # When 70% of system memory is used, start unloading
            "browser.tabs.unloadOnLowMemory" = true;
            "browser.tabs.min_inactive_duration_before_unload" = 1000 * 60 * 5; # 5 minutes before a tab can be unloaded
            "browser.tabs.inTitlebar" = 0; # Window border shadow (this turns it off) https://bugzilla.mozilla.org/show_bug.cgi?id=1765171

            # Reader mode always available
            "reader.parse-on-load.force-enabled" = true;

            "dom.private-attribution.submission.enabled" = false; # Could be cool eventually, but no incentive for websites to actually use this
            "middlemouse.paste" = false; # Disable paste on middle mouse button

            "widget.use-xdg-desktop-portal.file-picker" = 1;

            # https://github.com/yokoffing/Betterfox/blob/main/user.js
            "gfx.canvas.accelerated.cache-items" = 4096;
            "gfx.canvas.accelerated.cache-size" = 512;
            "gfx.content.skia-font-cache-size" = 20;
            "browser.cache.jsbc_compression_level" = 3;

            # Reject if cookie banner is one button
            "cookiebanners.service.mode" = 1;
            "cookiebanners.service.mode.privateBrowsing" = 1;

            # Remove fullscreen delay
            "full-screen-api.transition-duration.enter" = "0 0"; # default=200 200
            "full-screen-api.transition-duration.leave" = "0 0"; # default=200 200

            "full-screen-api.warning.delay" = -1; # default=500
            "full-screen-api.warning.timeout" = 0; # default=3000
          };
        };
      };
    };
  };
}
