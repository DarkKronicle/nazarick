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
      package = pkgs.firefox;

      nativeMessagingHosts = with pkgs; [ tridactyl-native ];

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

          settings = {
            # https://arkenfox.github.io/gui/
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
