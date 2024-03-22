{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

with lib;
with lib.nazarick;
let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  cfg = config.nazarick.plasma;
in
{
  options.nazarick.plasma = {
    enable = mkEnableOption "plasma";
    noBorders = mkBoolOpt false "Enable borders on windows";
  };

  config = mkIf cfg.enable {

    programs.plasma = {
      enable = true;

      workspace = {
        clickItemTo = "select";
        iconTheme = "Fluent-dark";
        colorScheme = "CatppuccinMochaMauve";
        cursorTheme = "Catppuccin-Mocha-Mauve";
      };

      configFile = mkMerge [
        {
          "kwinrc"."Windows"."RollOverDesktops" = true;

          "kwinrc"."Effect-wobblywindows"."Drag" = 85;
          "kwinrc"."Effect-wobblywindows"."Stiffness" = 10;
          "kwinrc"."Effect-wobblywindows"."WobblynessLevel" = 1;
          "kwinrc"."Plugins"."cubeEnabled" = true;
          "kwinrc"."Plugins"."shakecursorEnabled" = true;
          "kwinrc"."Plugins"."slideEnabled" = false;
          "kwinrc"."Plugins"."wobblywindowsEnabled" = true;

          "kdeglobals"."WM"."activeBlend" = "205,214,244";
          "kdeglobals"."WM"."activeForeground" = "205,214,244";
          "kdeglobals"."WM"."inactiveBackground" = "17,17,27";
          "kdeglobals"."WM"."inactiveBlend" = "166,173,200";
          "kdeglobals"."WM"."inactiveForeground" = "166,173,200";
        }
        (mkIf cfg.noBorders {

          "kwinrulesrc"."General"."count" = 1;
          "kwinrulesrc"."1"."Description" = "Remove Bars";
          "kwinrulesrc"."1"."noborder" = true;
          "kwinrulesrc"."1"."noborderrule" = 2;
          "kwinrulesrc"."1"."types" = 289;
          "kwinrulesrc"."1"."wmclass" = ".*";
          "kwinrulesrc"."1"."wmclasscomplete" = true;
          "kwinrulesrc"."1"."wmclassmatch" = 3;
          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."Description" = "Remove Bars";
          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."noborder" = true;
          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."noborderrule" = 2;
          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."types" = 289;
          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."wmclass" = ".*";
          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."wmclasscomplete" = true;
          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."wmclassmatch" = 3;
        })
      ];

      shortcuts = {
        "kwin"."Overview" = "Meta+W";
        "kwin"."Window Minimize" = "Meta+M";
        "services.org.kde.spectacle.desktop"."RectangularRegionScreenShot" = "Meta+Shift+S";
      };
    };
  };
}
