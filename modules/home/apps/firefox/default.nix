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
      # https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265/7
      package = pkgs.firefox;
      nativeMessagingHosts = with pkgs; [
        kdePackages.plasma-browser-integration
        tridactyl-native
      ];

      policies = {

        ExtensionSettings = lib.mkMerge [
          (

            let
              extension = shortId: uuid: {
                name = uuid;
                value = {
                  install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
                  installation_mode = "force_installed";
                };
              };
            in
            builtins.listToAttrs [
              (extension "adaptive-tab-bar-colour" "ATBC@EasonWong")
              (extension "better-canvas" "{8927f234-4dd9-48b1-bf76-44a9e153eee0}")
              (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
              (extension "darkreader" "addon@darkreader.org")
              (extension "dearrow" "deArrow@ajay.app")
              (extension "hide-youtube-shorts" "{88ebde3a-4581-4c6b-8019-2a05a9e3e938}")
              (extension "jump-cutter" "jump-cutter@example.com")
              (extension "libredirect" "7esoorv3@alefvanoon.anonaddy.me")
              (extension "privacy-badger17" "jid1-MnnxcxisBPnSXQ@jetpack")
              (extension "redirector" "redirector@einaregilsson.com")
              (extension "refined-github" "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}")
              (extension "sidebery" "{3c078156-979c-498b-8990-85f7987dd929}")
              (extension "smart-referer" "smart-referer@meh.paranoid.pk")
              (extension "sponsorblock" "sponsorBlocker@ajay.app")
              (extension "stylus" "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}")
              (extension "temporary-containers" "{c607c8df-14a7-4f28-894f-29e8722976af}")
              (extension "ublock-origin" "uBlock0@raymondhill.net")
              (extension "violentmonkey" "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}")
              (extension "yomitan" "{6b733b82-9261-47ee-a595-2dda294a4d08}")
            ]
          )
          {
            "*" = {
              instalation_mode = "blocked";
              blocked_install_message = "Erhm, please don't ;P";
            };
            "tridactyl.vim.betas@cmcaine.co.uk" = {
              install_url = "https://tridactyl.cmcaine.co.uk/betas/tridactyl-latest.xpi";
              installation_mode = "forced_installed";
            };
          }
        ];

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

          settings = {
            "privacy.resistFingerprinting" = true;
            "browser.uiCustomization.state" = builtins.readFile ./ui_state.json;

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
