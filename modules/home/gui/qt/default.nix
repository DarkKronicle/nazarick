{
  config,
  lib,
  pkgs,
  mypkgs,
  ...
}:
let
  cfg = config.nazarick.gui.qt;

  catpuccinQtct = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "qt5ct";
    rev = "89ee948e72386b816c7dad72099855fb0d46d41e";
    hash = "sha256-t/uyK0X7qt6qxrScmkTU2TvcVJH97hSQuF0yyvSO/qQ=";
  };
in
{

  options.nazarick.gui.qt = {
    enable = lib.mkEnableOption "qt";
  };
  config = lib.mkIf cfg.enable {

    # INFO: This will probably *not* set your system level environment variables, so make sure to do system stuff.
    qt = {
      enable = true;
      style.package = mypkgs.lightly-qt6;
      platformTheme.name = "qtct";
    };

    gtk = {
      iconTheme = {
        name = "Fluent-dark";
        package = pkgs.fluent-icon-theme;
      };
      cursorTheme = {
        package = pkgs.catppuccin-cursors.mochaMauve;
        name = "Catppuccin-Mocha-Mauve-Cursors";
      };
      theme.package = pkgs.kdePackages.breeze-gtk;
      enable = true;
      theme.name = "Breeze";
      gtk2.configLocation = "${config.home.homeDirectory}/.config/gtk-trash/gtkrc";
    };

    home.sessionVariables.GTK2_RC_FILES = lib.mkForce "${config.home.homeDirectory}/.gtkrc-2.0";

    home.packages = with pkgs; [
      mypkgs.lightly-qt6
      lightly-boehs # For qt5
      fluent-icon-theme
      kdePackages.qt6ct
      kdePackages.ark
      kdePackages.okular
      kdePackages.ffmpegthumbs
      kdePackages.kimageformats
      kdePackages.print-manager
      catppuccin-cursors.mochaMauve
    ];

    programs.wlogout.enable = true;

    # Make it so icons are nice and small
    xdg.configFile."dolphinrc" = {
      enable = true;
      text = ''
        [DetailsMode]
        PreviewSize=16

        [KFileDialog Settings]
        Places Icons Auto-resize=false
        Places Icons Static Size=22

        [MainWindow]
        MenuBar=Disabled
        ToolBarsMovable=Disabled

      '';

    };

    # This has to be inside this directory for some reason (can't link from wherever)
    # TODO: Actually maybe not

    # Quick and dirty way to get colors to apply for everything (including you, kdeconnect)
    # MVP this random forum post https://forum.endeavouros.com/t/getting-kdeconnect-to-use-kvantum-theme-outside-of-plasma/57717

    xdg.configFile."kdeglobals" = {
      enable = true;
      source = "${
        pkgs.catppuccin-kde.override {
          flavour = [ "mocha" ];
          accents = [ "mauve" ];
        }
      }/share/color-schemes/CatppuccinMochaMauve.colors";
    };

    xdg.configFile."qt5ct/colors/Catppuccin-Mocha.conf" = {
      enable = true;
      source = "${catpuccinQtct}/themes/Catppuccin-Mocha.conf";
    };

    xdg.configFile."qt6ct/colors/Catppuccin-Mocha.conf" = {
      enable = true;
      source = "${catpuccinQtct}/themes/Catppuccin-Mocha.conf";
    };

    xdg.configFile."qt5ct/qt5ct.conf" = {
      enable = true;
      source = pkgs.substitute {
        src = ./qt5ct.conf;
        substitutions = [
          "--replace-fail"
          "##COLORSCHEME##"
          "/home/${config.home.username}/.config/qt6ct/colors/Catppuccin-Mocha.conf"
        ];
      };
    };

    xdg.configFile."qt6ct/qt6ct.conf" = {
      enable = true;
      source = pkgs.substitute {
        src = ./qt6ct.conf;
        substitutions = [
          "--replace-fail"
          "##COLORSCHEME##"
          "/home/${config.home.username}/.config/qt6ct/colors/Catppuccin-Mocha.conf"
        ];
      };
    };
  };

}
