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
  copy_files = [
    # "/home/darkkronicle/.config/kwinrc"
    "/home/darkkronicle/.config/kglobalshortcutsrc"
    "/home/darkkronicle/.config/kconf_updaterc"
    "/home/darkkronicle/.config/kdeglobals"
    # "/home/darkkronicle/.config/plasmashellrc"
    "/home/darkkronicle/.config/spectaclerc"
    "/home/darkkronicle/.config/bluedevilglobalrc"
  ];
  jank_files = [ "/home/darkkronicle/.config/plasma-org.kde.plasma.desktop-appletsrc" ];
in
{
  options.nazarick.suites.impermanence = with types; {
    enable = mkBoolOpt false "Impermanence suite";
  };
  config = mkIf cfg.enable {
    impermanence.enable = true;

    # https://github.com/nix-community/impermanence/pull/146
    # systemd-journald.socket sysinit.target local-fs.target system.slice 
    systemd.services."setup-impermanence-copy" = {
      # after = lib.mkForce [ "local-fs.target" "systemd-journald.socket" "system.slice" ];
      after = [ "local-fs.target" ];
      unitConfig.DefaultDependencies = false;
      before = [ "sysinit.target" ];
      wantedBy = [ "local-fs.target" ];
      path = [
        pkgs.nushell
        pkgs.util-linux
        pkgs.btrfs-progs
      ];
      script = "${pkgs.nushell}/bin/nu ${./copy.nu} ${lib.concatMapStrings (x: x + " ") copy_files} ";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
    systemd.services."setup-jank-fixes" = {
      # after = lib.mkForce [
      # "local-fs.target"
      # "systemd-journald.socket"
      # "system.slice"
      # ];
      after = [ "local-fs.target" ];
      unitConfig.DefaultDependencies = false;
      before = [ "sysinit.target" ];
      wantedBy = [ "local-fs.target" ];
      path = [
        pkgs.nushell
        pkgs.util-linux
        pkgs.btrfs-progs
      ];
      script = "${pkgs.nushell}/bin/nu ${./jank.nu} ${lib.concatMapStrings (x: x + " ") jank_files} ";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };

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

        "/var/lib/upower"
        "/var/lib/nordvpn"
        "/root" # SSH keys + borg stuff, may not be needed anymore
        "/tmp" # Auto deletes regardless
      ];
    };

    # Stuff to back up
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
        ".config/drg_mod_integration"
        ".config/matlab"
        ".config/qalculate" # TODO: the qt file stores history, so don't delete that, but can set up setting some defaults
        ".config/easyeffects" # TODO: There is an option to set profile. The json should be stable
        ".borg"

        ".factorio"

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

        ".local/share/dolphin"

        # Keys
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
        # KDE stuff, holy heck. Some stuff that would normally go here has to go
        # in the copy script because bind mounting files can be weird
        # to check see if there are any OS `16 errors (Disk full?)`
        ".config/akregatorrc"
        # ".config/gtkrc"
        # ".config/gtkrc-2.0"
        ".config/gwenviewrc"
        ".config/katemetainfos"
        ".config/kateschemarc"
        ".config/katevirc"
        ".config/kcmfonts"
        ".config/konsolerc"
        ".config/ktimezonedrc"
        # ".config/kwinrulesrc"
        ".config/kwinoutputconfig.json"
        ".config/startkderc"
        # ".config/systemsettingsrc"
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

        ".config/autostart" # cursed things here

        ".config/qBittorrent"
        ".local/share/qBittorrent"

        ".config/fcitx5"

        ".cache/mozilla"
        ".cache/yazi"

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
        ".local/share/PrismLauncher"
        ".local/share/qalculate"

        ".pki"
        ".putty"

        ".steam"
        ".thunderbird"

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
