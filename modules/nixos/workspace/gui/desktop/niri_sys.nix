{
  lib,
  pkgs,
  mypkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.nazarick.workspace.gui.desktop.niri;

  niriWrapped = pkgs.runCommandNoCC "niri-school" { buildInputs = [ pkgs.makeWrapper ]; } ''
    makeWrapper ${pkgs.niri}/bin/niri-session $out/bin/niri-school-session --set SESSION_CONTEXT school
  '';

  sessionFile = ''
    [Desktop Entry]
    Name=Niri School
    Comment= A scrollable-tiling Wayland compositor
    Exec=${niriWrapped}/bin/niri-school-session
    Type=Application
  '';

  sessionPkg = pkgs.writeTextFile {
    name = "niri-school.desktop";
    text = sessionFile;
    destination = "/share/wayland-sessions/niri-school.desktop";
    derivationArgs = {
      passthru.providedSessions = [ "niri-school" ];
    };
  };
in
{
  options.nazarick.workspace.gui.desktop.niri = {
    enable = mkEnableOption "niri";
  };

  config = mkIf cfg.enable {

    programs.niri = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      xwayland-satellite
    ];

    services.displayManager.sessionPackages = [ sessionPkg ];

    nazarick.workspace.gui.sddm.defaultSession = "niri";
  };
}
