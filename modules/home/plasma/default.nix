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
        theme = "lightly-plasma-git";
        iconTheme = "Fluent-dark";
        colorScheme = "CatppuccinMochaMauve";
        cursorTheme = "Catppuccin-Mocha-Mauve";
      };

      configFile = mkMerge [
        {
          "kwinrc"."Windows"."RollOverDesktops".value = true;

          "kwinrc"."Effect-wobblywindows"."Drag".value = 85;
          "kwinrc"."Effect-wobblywindows"."Stiffness".value = 10;
          "kwinrc"."Effect-wobblywindows"."WobblynessLeve".value = 1;
          "kwinrc"."Plugins"."cubeEnable".value = true;
          "kwinrc"."Plugins"."shakecursorEnable".value = true;
          "kwinrc"."Plugins"."slideEnable".value = false;
          "kwinrc"."Plugins"."wobblywindowsEnable".value = true;

          "kdeglobals"."WM"."activeBlend".value = "205,214,244";
          "kdeglobals"."WM"."activeForeground".value = "205,214,244";
          "kdeglobals"."WM"."inactiveBackground".value = "17,17,27";
          "kdeglobals"."WM"."inactiveBlend".value = "166,173,200";
          "kdeglobals"."WM"."inactiveForeground".value = "166,173,200";
        }
        (mkIf cfg.noBorders {

          "kwinrulesrc"."General"."coun".value = 1;
          "kwinrulesrc"."1"."Descriptio".value = "Remove Bars";
          "kwinrulesrc"."1"."noborde".value = true;
          "kwinrulesrc"."1"."noborderrul".value = 2;
          "kwinrulesrc"."1"."type".value = 289;
          "kwinrulesrc"."1"."wmclas".value = ".*";
          "kwinrulesrc"."1"."wmclasscomplet".value = true;
          "kwinrulesrc"."1"."wmclassmatc".value = 3;
          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."Descriptio".value = "Remove Bars";
          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."noborde".value = true;
          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."noborderrul".value = 2;
          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."type".value = 289;
          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."wmclas".value = ".*";
          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."wmclasscomplet".value = true;
          "kwinrulesrc"."20f017d9-9443-48f9-a7ed-939eaf41284e"."wmclassmatc".value = 3;
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
