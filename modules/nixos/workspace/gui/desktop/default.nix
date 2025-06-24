{
  lib,
  pkgs,
  mypkgs,
  config,
  mylib,
  ...
}:
let
  cfg = config.nazarick.workspace.gui.desktop;

in
{
  options.nazarick.workspace.gui.desktop = {
    enable = lib.mkEnableOption "Base desktop environment (no window manager)";
  };

  imports = mylib.scanPaths ./.;

  config = lib.mkIf cfg.enable {
    # Brightness/volume
    nazarick.users.extraGroups = [ "video" ];
    programs.light.enable = true;

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

    environment.systemPackages = with pkgs; [
      kdePackages.qtwayland
      qt5.qtwayland
      networkmanagerapplet
    ];

    programs.ssh.startAgent = true;
    services.gnome.gcr-ssh-agent.enable = false;
    services.blueman.enable = true;

    environment.pathsToLink = [
      "/share/nushell"
    ];

    # TODO: maybe move?
    services.flatpak.enable = true;
  };

}
