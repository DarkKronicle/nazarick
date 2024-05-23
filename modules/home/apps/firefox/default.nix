{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.nazarick) mkBoolOpt;
  cfg = config.nazarick.apps.firefox;
  # https://github.com/gvolpe/nix-config/blob/6feb7e4f47e74a8e3befd2efb423d9232f522ccd/home/programs/browsers/firefox.nix
  custom-addons = pkgs.callPackage ./addons.nix {
    inherit (inputs.firefox-addons.lib.${pkgs.system}) buildFirefoxXpiAddon;
  };
in
{
  options.nazarick.apps.firefox = {
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
      };

      profiles = {
        main = {
          id = 0;
          name = "main";
          isDefault = true;
          userChrome = mkIf cfg.userCss ''
            @import "${pkgs.nazarick.firefox-cascade}/chrome/userChrome.css";
          '';

          search = {
            force = true;
            default = "SearXNG";
            engines = {
              "SearXNG" = {
                definedAliases = [ "@sx" ];
                urls = [
                  {
                    template = "https://searxng.ca/search";
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
              smart-referer
              sponsorblock
              stylus
              temporary-containers
              tridactyl # This has a beta option
              ublock-origin
              violentmonkey
              yomitan
            ])
            ++ (with custom-addons; [
              adaptive-tab-bar-colour
              better-canvas
              hide-youtube-shorts
            ]);

          settings = {
            "privacy.resistFingerprinting" = true;
            "browser.uiCustomization.state" = ((lib.nazarick.miniJSON pkgs) ./ui_state.json);

            # https://arkenfox.github.io/gui/
            "extensions.autoDisableScopes" = 0;
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

            # This is handled on system level now
            # "network.trr.uri" = "https://dns.quad9.net/dns-query"; 
            # "network.trr.custom_uri" = "https://dns.quad9.net/dns-query";

            # Don't touch
            "extensions.blocklist.enabled" = true;
            "network.http.referer.spoofSource" = false;
            "security.dialog_enable_delay" = 1000;
            "extensions.webcompat.enable_shims" = true;
            "extensions.webcompat-reporter.enabled" = false;
          };
        };
      };
    };
  };
}
