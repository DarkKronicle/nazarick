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

  firefox-cascade = pkgs.fetchFromGitHub {
    name = "firefox-cascade";
    owner = "DarkKronicle";
    repo = "cascade";
    rev = "994edba071341b4afa9483512d320696ea10c0a6";
    sha256 = "sha256-DX77qLtDktv077YksxnrSoqa8O0ujJF2NH36GkENaXI=";
  };

  extensions =
    (with inputs.firefox-addons.packages.${pkgs.system}; [
      bitwarden
      darkreader
      dearrow
      jump-cutter
      libredirect
      privacy-badger
      redirector
      refined-github
      sidebery
      smart-referer # DRM protection may break on stuff (crunchyroll), make sure to disable it for that website
      sponsorblock
      stylus
      temporary-containers
      tridactyl # This has a beta option
      ublock-origin
      violentmonkey
      yomitan
      no-pdf-download
      canvasblocker
      adaptive-tab-bar-colour
      lovely-forks # Shows forks on github projects
      catppuccin-gh-file-explorer
    ])
    ++ (with custom-addons; [
      better-canvas
      hide-youtube-shorts
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

    programs.firefox = {
      enable = true;
      # https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265/7
      package = pkgs.firefox;
      nativeMessagingHosts = with pkgs; [
        kdePackages.plasma-browser-integration
        tridactyl-native
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

      profiles = {
        main = {
          id = 0;
          name = "main";
          isDefault = true;
          userChrome = mkIf cfg.userCss ''
            @import "${firefox-cascade}/chrome/userChrome.css";
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

          settings = {
            # Good-bye weather
            "browser.newtabpage.activity-stream.feeds.weatherfeed" = false;
            "browser.newtabpage.activity-stream.showWeather" = false;
            "browser.newtabpage.activity-stream.system.showWeather" = false;
            "browser.newtabpage.activity-stream.weather.locationSearchEnabled" = false;

            "browser.low_commit_space_threshold_percent" = 30; # When 70% of system memory is used, start unloading
            "browser.tabs.unloadOnLowMemory" = true;
            "browser.tabs.min_inactive_duration_before_unload" = 1000 * 60 * 5; # 5 minutes before a tab can be unloaded
            "browser.tabs.inTitlebar" = 0; # Window border shadow (this turns it off) https://bugzilla.mozilla.org/show_bug.cgi?id=1765171

            "reader.parse-on-load.force-enabled" = true; # Reader mode always available
            "privacy.resistFingerprinting" = true;
            "browser.uiCustomization.state" = ((mylib.miniJSON pkgs) ./ui_state.json); # This has to be mini or it won't read it
            "extensions.autoDisableScopes" = 0;
            "privacy.resistFingerprinting.pbmode" = true;
            "browser.display.use_system_colors" = false;
            "privacy.resistFingerprinting.block_mozAddonManager" = false; # Can't install any new extensions if you get here lol
            "extensions.webextensions.restrictedDomains" = lib.concatStringsSep "," [
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

            "privacy.resistFingerprinting.letterboxing" = true;
            "webgl.disabled" = true;

            "dom.private-attribution.submission.enabled" = false; # Could be cool eventually, but no incentive for websites to actually use this

            "middlemouse.paste" = false; # Disable paste on middle mouse button

            # https://arkenfox.github.io/gui/
            "browser.contentanalysis.default_allow" = false;
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "widget.use-xdg-desktop-portal.file-picker" = 1;
            "browser.aboutConfig.showWarning" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.default.sites" = "";
            "extensions.getAddons.showPane" = false;
            "extensions.htmlaboutaddons.recommendations.enabled" = false;
            "browser.discovery.enabled" = false;
            "browser.shopping.experience2023.enabled" = false;
            "datareporting.policy.dataSubmissionEnabled" = false;
            "datareporting.healthreport.uploadEnabled" = false;
            "toolkit.telemetry.unified" = false;
            "toolkit.telemetry.enabled" = false;
            "toolkit.telemetry.server" = "data:,";
            "toolkit.telemetry.archive.enabled" = false;
            "toolkit.telemetry.newProfilePing.enabled" = false;
            "toolkit.telemetry.shutdownPingSender.enabled" = false;
            "toolkit.telemetry.updatePing.enabled" = false;
            "toolkit.telemetry.bhrPing.enabled" = false;
            "toolkit.telemetry.firstShutdownPing.enabled" = false;
            "toolkit.telemetry.coverage.opt-out" = true;
            "toolkit.telemetry.opt-out" = true;
            "toolkit.telemetry.endpoint.base" = "";
            "browser.ping-centre.telemetry" = false;
            "browser.newtabpage.activity-stream.feeds.telemetry" = false;
            "browser.newtabpage.activity-stream.telemetry" = false;
            "breakpad.reportURL" = false;
            "browser.tabs.crashReporting.sendReport" = false;
            "browser.crashReports.unsubmittedCheck.enabled" = false;
            "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
            "network.http.speculative-parallel-limit" = false;
            "browser.send_pings" = false;
            "browser.urlbar.pocket.featureGate" = false;
            "browser.urlbar.weather.featureGate" = false;
            "browser.urlbar.mdn.featureGate" = false;
            "browser.urlbar.addons.featureGate" = false;
            "browser.urlbar.trending.featureGate" = false;
            "browser.urlbar.suggest.quicksuggest.sponsored" = false;
            "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
            "browser.urlbar.speculativeConnect.enabled" = false;
            "security.ssl.require_safe_negotiation" = true; # May cause issues
            "dom.security.https_only_mode" = true;
            "network.http.referer.XOriginTrimmingPolicy" = 2; # May cause issues
            "network.IDN_show_punycode" = true;
            "browser.download.useDownloadDir" = false;
            "browser.download.alwaysOpenPanel" = false;
            "browser.download.manager.addToRecentDocs" = false;
            "browser.download.always_ask_before_handling_new_types" = false;
            "browser.contentblocking.category" = "strict"; # May cause issues
            "browser.link.open_newwindow" = 3; # May cause issues
            "browser.link.open_newwindow.restriction" = 0;

            "permissions.default.camera" = 0;
            "permissions.default.microphone" = 0;

            # dnscrypt-proxy2 baybee
            "network.trr.uri" = "https://127.0.0.1:3000/dns-query";
            "network.trr.custom_uri" = "https://127.0.0.1:3000/dns-query";
            "network.trr.mode" = 3;
            "network.dns.echconfig.enabled" = true;
            "network.dns.use_https_rr_as_altsvc" = true;

            # Don't touch
            "extensions.blocklist.enabled" = true;
            "network.http.referer.spoofSource" = false;
            "security.dialog_enable_delay" = 1000;
            "extensions.webcompat.enable_shims" = true;
            "extensions.webcompat-reporter.enabled" = false;

            # https://github.com/yokoffing/Betterfox/blob/main/user.js
            "gfx.canvas.accelerated.cache-items" = 4096;
            "gfx.canvas.accelerated.cache-size" = 512;
            "gfx.content.skia-font-cache-size" = 20;
            "browser.cache.jsbc_compression_level" = 3;

            "network.dns.disablePrefetch" = true;
            "network.dns.disablePrefetchFromHTTPS" = true;
            "network.prefetch-next" = false;
            "network.predictor.enabled" = false;
            "network.predictor.enable-prefetch" = false;

            "security.ssl.treat_unsafe_negotiation_as_broken" = true;
            "browser.xul.error_pages.expert_bad_cert" = true;
            "browser.privatebrowsing.forceMediaMemoryCache" = true;

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
