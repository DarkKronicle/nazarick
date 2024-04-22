{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.nazarick;
let
  cfg = config.nazarick.plasma.panels;
  cfgParent = config.nazarick.plasma;
in
{
  options.nazarick.plasma.panels = with types; {
    enable = mkEnableOption {
      description = ''
        Enable Plasma panels
      '';
      default = false;
    };
  };

  config = mkIf (cfg.enable && cfgParent.enable) {
    home.packages = with pkgs; [
      nazarick.kde-ginti
      nazarick.kde-application-title-bar
      nazarick.kde-plasmusic
      nazarick.kde-nordvpn
    ];

    programs.plasma = {
      panels = [
        {
          location = "bottom";
          alignment = "center";
          height = 40;
          hiding = "autohide";
          floating = true;
          screen = 0;
          # TODO: This is not a panel
          extraSettings = ''
            panel.lengthMode = "fit";
            let allDesktops = desktops();
            for (var desktopIndex = 0; desktopIndex < allDesktops.length; desktopIndex++) {
                var desktop = allDesktops[desktopIndex];
                desktop.wallpaperPlugin = "org.kde.slideshow";
                desktop.currentConfigGroup = Array("Wallpaper", "org.kde.slideshow", "General");
                desktop.writeConfig("SlidePaths", "${pkgs.nazarick.wallpapers}/share/wallpapers");
                desktop.writeConfig("SlideInterval", "3600"); // Seconds
            }
          '';
          widgets = [
            {
              name = "org.kde.plasma.kickoff";
              config = {
                General.icon = "nix-snowflake-white";
              };
            }
            {
              name = "org.kde.plasma.icontasks";
              config = {
                General = {
                  showOnlyCurrentActivity = "false";
                  showOnlyCurrentDesktop = "false";
                  launchers = lib.concatStrings (
                    lib.intersperse "," [
                      "applications:systemsettings.desktop"
                      "applications:org.kde.dolphin.desktop"
                      "applications:firefox.desktop"
                      "applications:kitty.desktop"
                      "applications:vesktop.desktop"
                      "applications:nheko.desktop"
                      # TODO: Wtf
                      # "file:///nix/store/rqkvi8w1vkvcav7xzn0594z8i4w9019f-home-manager-path/share/applications/anki.desktop"
                      "applications:betterbird.desktop"
                    ]
                  );
                };
              };
            }
            # Classic plasma jank strikes again! If there is no valid volume widget it just won't
            # set the volume correctly. Wonderful.
            # { name = "org.kde.plasma.volume"; }
            # { name = "org.kde.plasma.systemtray"; }
            # { name = "org.kde.plasma.digitalclock"; }
          ];
        }
        {
          location = "top";
          height = 22;
          hiding = "none";
          floating = false;
          screen = 0;
          widgets = [
            { name = "org.kde.plasma.ginti"; }
            {
              name = "com.github.antroids.application-title-bar";
              config = {
                Appearance = {
                  widgetElements = "windowIcon";
                  widgetMargins = "0";
                  windowTitleFontBold = "false";
                  windowTitleFontSize = "10";
                  windowTitleFontSizeMode = "Fit";
                  windowTitleHideEmpty = "true";
                  windowTitleMarginsLeft = "5";
                  windowTitleMarginsRight = "5";
                  windowTitleUndefined = "";
                };
                Behavior = {
                  widgetActiveTaskSource = "LastActiveTask";
                  widgetMouseAreaMiddleLongPressAction = "Kill Window";
                  widgetMouseAreaWheelDownAction = "Walk Through Windows of Current Application";
                  widgetMouseAreaWheelUpAction = "Walk Through Windows of Current Application (Reverse)";
                };
              };
            }
            { name = "org.kde.plasma.appmenu"; }
            { name = "org.kde.plasma.panelspacer"; }
            {
              name = "plasmusic-toolbar";
              config = {
                General = {
                  textScrollingSpeed = "1"; # Kind of bugged where it will just scroll even though I don't want it to, so lets make it slow
                  useAlbumCoverAsPanelIcon = "true";
                  textScrollingBehaviour = "1";
                  albumCoverRadius = "0";
                  # Incredibly jank, but in the code it checks for desktop files. spotifyd has no desktop file, so it needs to be blank
                  # https://github.com/ccatterina/plasmusic-toolbar/blob/f1bb8b7c2c39ffc76800059fa7c0bae15eefe6c5/src/contents/ui/Player.qml#L12
                  sourceIndex = "4";
                  sources = "any,spotify,vlc,spotifyd,,spotifyd ,spotifyd.instance5344,spotifyd.instance";
                };
              };
            }
            # { name = "com.github.korapp.nordvpn"; }
            { name = "org.kde.plasma.systemtray"; }
            {
              name = "org.kde.plasma.digitalclock";
              config = {
                Appearance = {
                  showDate = "false";
                };
              };
            }
          ];
          extraSettings = (
            readFile (
              pkgs.substituteAll {
                src = ./system-tray.js;
                iconSpacing = 1;
                scaleIconsToFit = toString false;
                shownItems = concatStringsSep "," [ "org.kde.plasma.volume" ];
                hiddenItems = concatStringsSep "," [
                  "chrome_status_icon_1"
                  "kded6"
                  "org.kde.plasma.clipboard"
                  "org.kde.plasma.keyboardlayout"
                  "org.kde.plasma.mediacontroller"
                  "Fcitx"
                ];
                # knownItems = concatStringsSep "," [
                # Essentially disabled ones. Known but not in extra or shown
                # "com.github.korapp.nordvpn"
                # ];
                popupHeight = "432";
                popupWidth = "432";
              }
            )
          );
        }
        {
          location = "top";
          height = 22;
          hiding = "none";
          floating = false;
          screen = 1;
          widgets = [
            # { name = "org.kde.plasma.ginti"; }
            {
              name = "com.github.antroids.application-title-bar";
              config = {
                Appearance = {
                  widgetElements = "windowIcon";
                  widgetMargins = "0";
                  windowTitleFontBold = "false";
                  windowTitleFontSize = "10";
                  windowTitleFontSizeMode = "Fit";
                  windowTitleHideEmpty = "true";
                  windowTitleMarginsLeft = "5";
                  windowTitleMarginsRight = "5";
                  windowTitleUndefined = "";
                };
                Behavior = {
                  widgetActiveTaskSource = "LastActiveTask";
                  widgetMouseAreaMiddleLongPressAction = "Kill Window";
                  widgetMouseAreaWheelDownAction = "Walk Through Windows of Current Application";
                  widgetMouseAreaWheelUpAction = "Walk Through Windows of Current Application (Reverse)";
                };
              };
            }
            { name = "org.kde.plasma.appmenu"; }
            { name = "org.kde.plasma.panelspacer"; }
            {
              name = "org.kde.plasma.digitalclock";
              config = {
                Appearance = {
                  showDate = "false";
                };
              };
            }
          ];
          extraSettings = (
            readFile (
              pkgs.substituteAll {
                src = ./system-tray.js;
                iconSpacing = 1;
                scaleIconsToFit = toString false;
                shownItems = concatStringsSep "," [ "org.kde.plasma.volume" ];
                hiddenItems = concatStringsSep "," [
                  "chrome_status_icon_1"
                  "kded6"
                  "org.kde.plasma.clipboard"
                  "org.kde.plasma.keyboardlayout"
                  "org.kde.plasma.mediacontroller"
                  "Fcitx"
                ];
                knownItems = concatStringsSep "," [
                  # Essentially disabled ones. Known but not in extra or shown
                  "com.github.korapp.nordvpn"
                ];
                popupHeight = "432";
                popupWidth = "432";
              }
            )
          );
        }
      ];
    };
  };
}
