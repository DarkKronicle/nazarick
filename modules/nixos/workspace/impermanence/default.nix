{
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.nazarick.workspace.impermanence;
in
{
  options.nazarick.workspace.impermanence = {
    enable = mkBoolOpt false "Impermanence suite";
  };
  config = mkIf cfg.enable {
    impermanence.enable = true;

    environment.persist = {
      hideMounts = true;
      files = [
        # REQUIRED
        "/etc/machine-id"
        "/etc/adjtime"
      ];

      directories = [
        # REQUIRED
        "/var/log"
        "/var/lib/systemd"
        "/var/lib/nixos"
        "/var/lib/sops-nix"

        # System state that isn't declarative
        "/var/lib/cups"
        "/var/cache/cups"
        "/var/lib/NetworkManager"
        "/var/lib/bluetooth"
        "/etc/NetworkManager"
        "/var/lib/dnscrypt-proxy"

        "/var/lib/upower"
        "/var/lib/nordvpn"
        "/root" # SSH keys + borg stuff, may not be needed anymore
        "/tmp" # Auto deletes regardless
      ];
    };

    # Stuff to back up
    # TODO: this should be configured in home, but be sourced here
    environment.keepPersist.users.darkkronicle = {

      directories = [
        # User files
        "Documents"
        "Pictures"

        # System configuration
        "nazarick"

        ".config/nvim"
        ".local/share/atuin"
        ".local/share/Anki2"
        ".config/filezilla"
        ".config/mint"
        ".config/matlab"
        ".config/qalculate" # TODO: the qt file stores history, so don't delete that, but can set up setting some defaults
        ".borg"

        ".factorio"

        # KDE stuff
        ".config/gtk-3.0"
        ".config/gtk-4.0"
        ".config/KDE"
        ".config/kde.org"
        ".config/plasma-workspace"
        ".config/xsettingsd"
        ".config/newsboat" # TODO: Decide if I want urls declarative or not
        ".kde"

        ".local/share/baloo"
        ".local/share/kscreen"
        ".local/share/kwalletd"
        ".local/share/sddm"
        ".local/share/keyrings"

        ".local/share/dolphin"
        ".config/GIMP"
        ".config/krita"
        ".local/share/krita"

        # Keys
        {
          directory = ".ssh";
          mode = "0700";
        }
        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".config/sops/age";
          mode = "0700";
        }
      ];
    };

    environment.transientPersist.users.darkkronicle = {
      files = [
        # KDE stuff, holy heck. Some stuff that would normally go here has to go
        # in the copy script because bind mounting files can be weird
        # to check see if there are any OS `16 errors (Disk full?)`
        ".config/akregatorrc"
        ".config/gwenviewrc"
        ".config/katemetainfos"
        ".config/kateschemarc"
        ".config/katevirc"
        ".config/kcmfonts"
        ".config/konsolerc"
        ".config/ktimezonedrc"
        ".config/kwinoutputconfig.json"
        ".config/startkderc"
        ".config/Trolltech.conf"
        ".config/user-dirs.dirs"
        ".config/user-dirs.locale"

        ".local/share/krunnerstaterc"

        ".cache/plasma_theme_lightly-plasma-git.kcache"
        ".cache/plasma_theme_internal-system-colors.kcache"
        ".cache/plasma_theme_default_v5.113.0.kcache"
      ];

      directories = [
        # "tmp"
        "Downloads"
        ".local/state/mpv/watch_later"
        ".cache/thumbnails"
        ".vim"

        # non-nix store apps
        ".applications/matlab"
        ".MathWorks"
        ".matlab"
        ".MATLABConnector"
        ".cache/mkWindowsApp"

        ".mozilla"
        ".local/share/Steam"
        ".local/share/vulkan"

        ".local/share/Trash"
        ".local/share/zoxide"
        ".local/share/direnv"

        ".config/nordvpn"
        ".config/borg"
        ".config/kdeconnect"
        ".config/vesktop"
        ".config/unity3d"
        ".config/Mumble"
        ".config/nixpkgs"
        ".config/kdedefaults"
        ".config/kded5"
        ".config/kded6"

        ".config/kraxarn"

        ".config/autostart" # cursed things here

        ".config/qBittorrent"
        ".local/share/qBittorrent"

        ".config/fcitx5"

        ".cache/mozilla"
        ".cache/yazi"
        ".cache/newsboat"
        ".local/share/newsboat"

        ".local/share/klipper"
        ".local/share/kactivitymanagerd"
        ".local/share/applications"
        ".local/share/color-schemes"
        ".local/share/knewstuff3"
        ".local/share/kpackage"
        ".local/share/icons"
        ".local/share/lib"
        ".local/share/Mumble"
        ".local/share/mint"
        ".local/share/nvim"
        ".local/state/nvim"
        ".local/state/wireplumber"
        ".local/share/PrismLauncher"
        ".local/share/qalculate"
        # This is important so that the restoreToken gets properly persisted, sad thing is this doesn't work after a reboot, so it's 
        # not really needed right now. https://bugs.kde.org/show_bug.cgi?id=480235
        ".local/share/kdeconnect.daemon"

        ".pki"
        ".putty"

        ".steam"
        ".thunderbird"

        ".config/nheko"
        ".local/share/nheko"
        ".cache/nheko"

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
        ".cache/kscreenlocker_greet"
        ".cache/lua-language-server"
        ".cache/mesa-shader-cache"
        ".cache/mint"
        ".cache/nix"
        ".cache/nvim"
        ".cache/pypoetry"
        ".cache/starship"
        ".cache/systemsettings" # doubt
        ".cache/tealdeer"
        ".cache/zoxide"
      ];
    };
  };
}
