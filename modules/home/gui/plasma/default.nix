{
  lib,
  config,
  mylib,
  pkgs,
  mypkgs,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;
  inherit (mylib) mkBoolOpt;

  cfg = config.nazarick.gui.plasma;
in
{
  imports = [ ./panels ];

  options.nazarick.gui.plasma = {
    enable = mkEnableOption "plasma";
    noBorders = mkBoolOpt false "Enable borders on windows";
  };

  config = mkIf cfg.enable {

    # gtk 2 config conflicts with *something*, so move it somewhere else to forget about it
    gtk = {
      theme.package = pkgs.kdePackages.breeze-gtk;
      enable = true;
      theme.name = "Breeze";
      gtk2.configLocation = "${config.home.homeDirectory}/.config/gtk-trash/gtkrc";
    };

    home.sessionVariables.GTK2_RC_FILES = lib.mkForce "${config.home.homeDirectory}/.gtkrc-2.0";

    home.packages =
      [ mypkgs.kde-citygrow ]
      ++ (with pkgs; [
        fluent-icon-theme
        (kdePackages.callPackage ./lightly-qt6.nix { })
        (catppuccin-kde.override {
          flavour = [ "mocha" ];
          accents = [ "mauve" ];
        })
        (rofimoji.override { x11Support = false; })
      ]);

    programs.plasma = {
      enable = true;
      overrideConfig = true;

      workspace = {
        clickItemTo = "select";
        theme = "lightly-plasma-git";
        iconTheme = "Fluent-dark";
        colorScheme = "CatppuccinMochaMauve";
        cursorTheme = "Catppuccin-Mocha-Mauve-Cursors";
        wallpaperSlideShow = {
          interval = 3600; # Seconds
          path = [ "${mypkgs.system-wallpapers}/share/wallpapers/system-wallpapers" ];
        };
      };

      hotkeys.commands = {
        "screenshot" = {
          name = "Screenshot Region";
          key = "Meta+Shift+S";
          command = "kstart -- spectacle -r";
        };
        "application-tofi" = {
          name = "Tofi Application Selector";
          key = "Meta+Ctrl+L";
          # This may have an error if the application start has a string with a space in it
          command = ''nu -c "tofi-drun | kstart -- ...(\\$in | str trim | split row ' ')"'';
        };
        "symbols-tofi" = {
          name = "Tofi Symbols Selector";
          key = "Meta+Ctrl+K";
          command = ''rofimoji --selector tofi --clipboarder wl-copy --action type copy --files kaomoji arrows math mathematical_operators emojis_smileys_emotion --prompt "> " --selector-args="--num-results=15 --result-spacing=15 --padding-left=10% --padding-top=10% --font-size=20"'';
        };
        "nerd-tofi" = {
          name = "Tofi Nerd Font Selector";
          key = "Meta+Ctrl+N";
          command = ''rofimoji --selector tofi --clipboarder wl-copy --action type copy --files kaomoji nerd_font --prompt "> " --selector-args="--num-results=15 --result-spacing=15 --padding-left=10% --padding-top=10% --font-size=20"'';
        };
      };

      kwin = {
        effects = {
          shakeCursor.enable = true;
        };
        virtualDesktops = {
          # animation = "slide";
          rows = 2;
          names = [
            "Desktop 1"
            "Desktop 2"
            "Desktop 3"
            "Desktop 4"
            "Desktop 5"
            "Desktop 6"
          ];
        };
      };

      configFile = lib.mkMerge [
        {
          "kdeglobals"."KDE"."widgetStyle".value = "Lightly";

          "kwinrc"."Windows"."RollOverDesktops".value = true;

          "kwinrc"."Effect-wobblywindows"."Drag".value = 85;
          "kwinrc"."Effect-wobblywindows"."Stiffness".value = 10;
          "kwinrc"."Effect-wobblywindows"."WobblynessLevel".value = 1;
          "kwinrc"."Plugins"."cubeEnabled".value = true;
          "kwinrc"."Plugins"."shakecursorEnable".value = true;
          "kwinrc"."Plugins"."slideEnabled".value = false;
          "kwinrc"."Plugins"."wobblywindowsEnabled".value = true;
          "kwinrc"."Plugins"."scaleEnabled".value = false;
          # "kwinrc"."Plugins"."squashEnabled".value = true;

          "kdeglobals"."WM"."activeBlend".value = "205,214,244";
          "kdeglobals"."WM"."activeForeground".value = "205,214,244";
          "kdeglobals"."WM"."inactiveBackground".value = "17,17,27";
          "kdeglobals"."WM"."inactiveBlend".value = "166,173,200";
          "kdeglobals"."WM"."inactiveForeground".value = "166,173,200";
          # TODO: Make this use the package declaration
          "kwinrc"."Wayland"."InputMethod[$e]".value = "/run/current-system/sw/share/applications/org.fcitx.Fcitx5.desktop";
          "dolphinrc"."DetailsMode"."PreviewSize".value = 16;
          "dolphinrc"."KFileDialog Settings"."Places Icons Auto-resize".value = false;
          "dolphinrc"."KFileDialog Settings"."Places Icons Static Size".value = 22;
          "kcminputrc"."Libinput/1/1/kanata"."PointerAcceleration".value = 0.0;
          "kcminputrc"."Libinput/1/1/kanata"."PointerAccelerationProfile".value = 1;
          "kcminputrc"."Libinput/7805/11446/ROCCAT ROCCAT Kone XP Air Dongle"."PointerAccelerationProfile".value =
            1;
          "kcminputrc"."Mouse"."X11LibInputXAccelProfileFlat".value = true;
          "kcminputrc"."Tmp"."update_info".value = "delete_cursor_old_default_size.upd:DeleteCursorOldDefaultSize";
          "plasma-localerc"."Formats"."LANG".value = "en_US.UTF-8";
          "systemsettingsrc"."KFileDialog Settings"."detailViewIconSize".value = 16;
          "plasmanotifyrc"."Notifications"."PopupPosition".value = "BottomRight";
          "kscreenlockerrc"."Greeter"."WallpaperPlugin".value = "org.kde.plasma.citygrow";
          "kcminputrc"."Keyboard"."NumLock".value = 0;
          "klaunchrc"."BusyCursorSettings"."Bouncing".value = false;
          "klaunchrc"."FeedbackStyle"."BusyCursor".value = false;
        }
        (mkIf cfg.noBorders {

          "kwinrulesrc"."1"."Description".value = "Remove Bars";
          "kwinrulesrc"."1"."noborder".value = true;
          "kwinrulesrc"."1"."noborderrule".value = 2;
          "kwinrulesrc"."1"."types".value = 289;
          "kwinrulesrc"."1"."wmclass".value = ".*";
          "kwinrulesrc"."1"."wmclasscomplete".value = true;
          "kwinrulesrc"."1"."wmclassmatch".value = 3;

          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."Description".value = "Remove Bars";
          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."noborder".value = true;
          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."noborderrule".value = 2;
          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."types".value = 289;
          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."wmclass".value = ".*";
          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."wmclasscomplete".value = true;
          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."wmclassmatch".value = 3;

          "kwinrulesrc"."9ea16ad3-5d63-4746-8e63-cd888f14951b"."Description".value = "Mumble settings";
          "kwinrulesrc"."9ea16ad3-5d63-4746-8e63-cd888f14951b"."above".value = true;
          "kwinrulesrc"."9ea16ad3-5d63-4746-8e63-cd888f14951b"."aboverule".value = 3;
          "kwinrulesrc"."9ea16ad3-5d63-4746-8e63-cd888f14951b"."opacityactiverule".value = 2;
          "kwinrulesrc"."9ea16ad3-5d63-4746-8e63-cd888f14951b"."opacityinactive".value = 70;
          "kwinrulesrc"."9ea16ad3-5d63-4746-8e63-cd888f14951b"."opacityinactiverule".value = 2;
          "kwinrulesrc"."9ea16ad3-5d63-4746-8e63-cd888f14951b"."size".value = "250,435";
          "kwinrulesrc"."9ea16ad3-5d63-4746-8e63-cd888f14951b"."sizerule".value = 3;
          "kwinrulesrc"."9ea16ad3-5d63-4746-8e63-cd888f14951b"."types".value = 1;
          "kwinrulesrc"."9ea16ad3-5d63-4746-8e63-cd888f14951b"."wmclass".value = "mumble info.mumble.Mumble";
          "kwinrulesrc"."9ea16ad3-5d63-4746-8e63-cd888f14951b"."wmclasscomplete".value = true;
          "kwinrulesrc"."9ea16ad3-5d63-4746-8e63-cd888f14951b"."wmclassmatch".value = 1;

          "kwinrulesrc"."General"."count".value = 2;
          "kwinrulesrc"."General"."rules".value = "1,9ea16ad3-5d63-4746-8e63-cd888f14951b";
        })
      ];

      shortcuts = {
        "kwin"."Overview" = "Meta+W";
        "kwin"."Window Minimize" = "Meta+M";
        # This is broken
        # "services/org.kde.spectacle.desktop"."ActiveWindowScreenShot" = [ ];
        # "services/org.kde.spectacle.desktop"."FullScreenScreenShot" = [ ];
        # "services/org.kde.spectacle.desktop"."RecordRegion" = [ ];
        # "services/org.kde.spectacle.desktop"."RecordScreen" = [ ];
        # "services/org.kde.spectacle.desktop"."RecordWindow" = [ ];
        # "services/org.kde.spectacle.desktop"."WindowUnderCursorScreenShot" = [ ];
        # "services/org.kde.spectacle.desktop"."_launch" = [ ];
        # "services/org.kde.spectacle.desktop"."RectangularRegionScreenShot" = "Meta+Ctrl+S";
        # "services/services.org.kde.spectacle.desktop"."RectangularRegionScreenShot" = "Meta+Shift+S";
      };
    };
  };
}
