{
  lib,
  pkgs,
  mypkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.nazarick.workspace.gui.desktop.sway;

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
  options.nazarick.workspace.gui.desktop.sway = {
    enable = mkEnableOption "sway";
  };

  config = mkIf cfg.enable {

    environment.etc."sway/config.d/session.conf".source = pkgs.writeText "session.conf" ''
      exec dbus-update-activation-environment --systemd SESSION_CONTEXT
    '';

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
      '';
      wrapperFeatures.gtk = true;
    };

    services.displayManager.sessionPackages = [ sessionPkg ];

    nazarick.workspace.gui.sddm.defaultSession = "sway";
  };
}
