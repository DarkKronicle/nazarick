{
  lib,
  pkgs,
  mypkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.nazarick.workspace.gui.sway;

  package = pkgs.swayfx;

  swayWrapped =
    let
      sway = config.programs.sway.package;
    in
    pkgs.runCommandNoCC "sway-school" { buildInputs = [ pkgs.makeWrapper ]; } ''
      makeWrapper ${sway}/bin/sway $out/bin/sway-school --set SESSION_CONTEXT school
    '';

  sessionFile = ''
    [Desktop Entry]
    Name=SwayFX School
    Comment=An i3-compatible Wayland compositor
    Exec=${swayWrapped}/bin/sway-school
    Type=Application
  '';

  sessionPkg = pkgs.writeTextFile {
    name = "sway-school.desktop";
    text = sessionFile;
    destination = "/share/wayland-sessions/sway-school.desktop";
    derivationArgs = {
      passthru.providedSessions = [ "sway-school" ];
    };
  };
in
{
  options.nazarick.workspace.gui.sway = {
    enable = mkEnableOption "sway";
  };

  config = mkIf cfg.enable {
    # Brightness/volume
    nazarick.users.extraGroups = [ "video" ];
    programs.light.enable = true;

    # Don't love gnome stuff, but works well enough here. Another option is keepassxs, 
    # that won't autostart

    # Doesn't work well with sddm I think
    # https://github.com/NixOS/nixpkgs/issues/86884
    services.gnome.gnome-keyring.enable = lib.mkDefault true;
    programs.seahorse.enable = true;

    # Autostart won't happen here bc not gnome, and too much work modifying autostart files
    systemd.user.services."gnome-keyring-secret" = {
      wantedBy = [ "graphical-session-pre.target" ];
      description = "Gnome Keyring Daemon";
      script = "/run/wrappers/bin/gnome-keyring-daemon --start --components=secrets";
    };

    # Maybe change this? But sddm with my theme is pretty cool
    services.displayManager.sddm.wayland.enable = true;

    environment.etc."sway/config.d/session.conf".source = pkgs.writeText "session.conf" ''
      exec dbus-update-activation-environment --systemd SESSION_CONTEXT
    '';

    environment.systemPackages = with pkgs; [
      kdePackages.qtwayland
      qt5.qtwayland
      networkmanagerapplet
    ];

    # Majority of stuff is configured in home manager land
    programs.sway = {
      inherit package;
      enable = true;
      extraPackages = [ pkgs.foot ]; # No defaults please (just foot incase of worst case)
      extraOptions = [
        "--unsupported-gpu" # not going to use open source :(
      ];
      extraSessionCommands = ''
        export WLR_NO_HARDWARE_CURSORS=1
        export QT_QPA_PLATFORM=wayland
        export QT_QPA_PLATFORMTHEME=qt5ct
        export _JAVA_AWT_WM_NONREPARENTING=1
      ''; # QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      wrapperFeatures.gtk = true;
    };

    services.blueman.enable = true;

    services.displayManager.sessionPackages = [ sessionPkg ];

  };
}
