{
  config,
  options,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.nazarick;
let
  cfg = config.nazarick.suites.impermanence;
in
{
  options.nazarick.suites.impermanence = with types; {
    enable = mkBoolOpt false "Impermanence suite";
  };
  config = mkIf cfg.enable {
    impermanence.enable = true;

    environment.persist = {
      hideMounts = true;
      files = [
        "/etc/machine-id"
        "/etc/adjtime"
      ];

      directories = [
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/cups"
        "/var/cache/cups"
        "/var/lib/NetworkManager"
        "/var/lib/sops-nix"
        "/var/lib/systemd"
        "/var/lib/upower"
        "/var/lib/nordvpn"
        "/etc/NetworkManager"
        "/root" # SSH keys + borg stuff, may not be needed anymore
        "/tmp" # Auto deletes regardless
      ];
    };

    environment.keepPersist.users.darkkronicle = {
      files = [
        # ".config/nushell/history.txt"
      ];

      directories = [
        ".config/nvim"
        ".local/share/Anki2"
        ".config/filezilla"
        ".config/drg_mod_integration"
        ".config/matlab"
        ".config/mpv"
        ".config/qalculate"
        ".config/easyeffects"
        ".local/share/atuin"
        ".borg"

        "nazarick"
        ".factorio"

        "Documents"
        "Pictures"

        # KDE stuff
        ".config/gtk-3.0"
        ".config/gtk-4.0"
        ".config/KDE"
        ".config/kde.org"
        ".config/plasma-workspace"
        ".config/xsettingsd"
        ".kde"

        ".local/share/baloo"
        ".local/share/kscreen"
        ".local/share/kwalletd"
        ".local/share/sddm"

        # TODO: Can be declarative
        ".local/share/dolphin"

        {
          directory = ".ssh";
          mode = "0700";
        }
        {
          directory = ".gnupg";
          mode = "0700";
        }
      ];
    };

    environment.transientPersist.users.darkkronicle = {
      files = [
        # KDE stuff, holy heck
        ".config/akregatorrc"
        ".config/baloofilerc"
        ".config/bluedevilglobalrc"
        ".config/dolphinrc"
        ".config/gtkrc"
        ".config/gtkrc-2.0"
        ".config/gwenviewrc"
        ".config/kactivitymanagerd-statsrc"
        ".config/kactivitymanagerdrc"
        ".config/katemetainfos"
        ".config/katerc"
        ".config/kateschemarc"
        ".config/katevirc"
        ".config/kcmfonts"
        ".config/kcminputrc"
        ".config/kconf_updaterc"
        ".config/kded5rc"
        ".config/kdeglobals"
        ".config/kglobalshortcutsrc"
        ".config/khotkeysrc"
        ".config/kmixrc"
        ".config/konsolerc"
        ".config/kscreenlockerrc"
        ".config/ksmserverrc"
        ".config/ktimezonedrc"
        ".config/kwinrc"
        ".config/kwinrulesrc"
        ".config/kwinoutputconfig.json"
        ".config/kxkbrc"
        ".config/plasma-localerc"
        ".config/plasma-org.kde.plasma.desktop-appletsrc"
        ".config/plasmanotifyrc"
        ".config/plasmashellrc"
        ".config/spectaclerc"
        ".config/startkderc"
        ".config/systemsettingsrc"
        ".config/Trolltech.conf"
        ".config/user-dirs.dirs"
        ".config/user-dirs.locale"

        ".local/share/krunnerstaterc"
        # ".local/share/user-places.xbel"
        # ".local/share/user-places.xbel.bak"
        # ".local/share/user-places.xbel.tbcache"

        ".cache/plasma_theme_lightly-plasma-git.kcache"
        ".cache/plasma_theme_internal-system-colors.kcache"
        ".cache/plasma_theme_default_v5.113.0.kcache"
      ];

      directories = [
        ".config/nordvpn"
        ".config/borg"
        ".config/kdeconnect"
        ".config/vesktop"
        ".config/unity3d"
        ".config/Mumble"
        ".config/nheko"
        ".config/nixpkgs"
        ".config/kdedefaults"
        ".config/kded5"
        ".config/kded6"
        ".mozilla"
        ".cache/mozilla"
        ".applications/matlab"
        "Downloads"
        ".local/share/klipper"
        ".local/share/kactivitymanagerd"
        ".local/share/applications"
        ".local/share/color-schemes"
        ".local/share/knewstuff3"
        ".local/share/kpackage"
        ".local/share/icons"
        ".local/share/lib"
        ".local/share/Mumble"
        ".local/share/nheko"
        ".local/share/nvim"
        ".local/state/nvim"
        ".local/state/wireplumber"
        ".local/share/plasma"
        ".local/share/PrismLauncher"
        ".local/share/plasma-manager"
        ".local/share/qalculate"

        ".local/share/Steam"
        ".local/share/vulkan"

        ".local/share/Trash"
        ".local/share/zoxide"

        ".pki"
        ".putty"

        ".MathWorks"
        ".matlab"
        ".MATLABConnector"

        ".steam"
        # TODO: Auto delete this, trash, and downloads
        ".vim"

        ".wifi"
        ".wine"
        ".codeium"
        ".cargo"

        ".cache/bat"
        ".cache/bookmarksrunner"
        ".cache/borg"
        ".cache/filezilla" # wtf
        ".cache/fontconfig"
        ".cache/gstreamer"
        ".cache/atuin" # do I need this one?
        ".cache/nheko"
        ".cache/kscreenlocker_greet"
        ".cache/lua-language-server"
        ".cache/mesa-shader-cache"
        ".cache/mint"
        ".cache/mkWindowsApp"
        ".cache/nix"
        ".cache/nvim"
        ".cache/pypoetry"
        ".cache/starship"
        ".cache/systemsettings" # doubt
        ".cache/tealdeer"
        ".cache/zoxide"
        ".cache/thumbnails"
      ];
    };
  };
}
