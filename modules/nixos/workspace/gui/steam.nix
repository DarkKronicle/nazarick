{
  options,
  config,
  lib,
  mylib,
  pkgs,
  inputs,
  system,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;
  cfg = config.nazarick.workspace.gui.steam;

in
{
  options.nazarick.workspace.gui.steam = {
    enable = mkBoolOpt false "Enable Steam";
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
    };
    programs.steam.gamescopeSession.enable = true;
    programs.gamemode = {
      enable = true;
      enableRenice = true;
    };

    # This does not work. Gamescope with no renice also kinda sucks
    # security.wrappers.gamescope = lib.mkForce {
    # owner = "root";
    # group = "users";
    # source = "${pkgs.gamescope}/bin/gamescope";
    # setuid = true;
    # setgid = true;
    # capabilities = "all+pie";
    # };

    # https://github.com/TLATER/dotfiles/blob/5eb6f6ac73e2324e3d5ccac9b73fe1f2358ef451/nixos-config/hosts/yui/games.nix#L24C5-L38C1
    # Good defaults
    programs.gamescope = {
      enable = true;
      # https://github.com/NixOS/nixpkgs/issues/208936
      capSysNice = true; # This doesn't work right now bc of reasons. Maybe bwrap? Maybe not?
      # Launch games like:
      # gamescope -- gamemoderun %command%
      # args = [
      # "--steam"
      # "--expose-wayland"
      # "--rt"
      # "-W 2560"
      # "-H 1440"
      # "--force-grab-cursor"
      # "--grab"
      # "--fullscreen"
      # ];
    };

    security.wrappers.bwrap = lib.mkForce {
      owner = "root";
      group = "root";
      source = "${pkgs.bubblewrap}/bin/bwrap";
      setuid = false;
    };
    # This works with xbox controllers. If it can't connect (connection/disconnect cycles...)
    # You can *try* to update the firmware, or go as far as to connect with it on Windows with the
    # same bluetooth card.
    hardware.xpadneo.enable = true;

    environment.systemPackages = with pkgs; [
      protonup
      inputs.mint.packages.${system}.mint
    ];
  };
}
