# This can't be hardened like the system one, so maybe make a puppet to send cmds over to?
# Make sure that your user has input/uinput groups and that system hardware.uinput is enabled
{
  options,
  config,
  lib,
  mylib,
  pkgs,
  mypkgs,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.nazarick.service.kanata;

  tofiApp = pkgs.writeScriptBin "tofi_app" ''
    pkill tofi || nu -c "tofi-drun | swaymsg exec -- ...(\$in | str trim | split row ' ')"
  '';

  packages = [
    pkgs.swayfx
    mypkgs.scripts.swu
    tofiApp
  ];

  mkKanataService =
    { name, file }:
    {
      Install = {
        WantedBy = [ "graphical-session.target" ]; # Make sure sway stuff is loaded into the session
      };

      Unit = {
        Description = "Kanata remapper for ${name}";
        Documentation = "https://github.com/jtroo/kanata";
      };

      Service = {
        Environment = [ "PATH=${lib.makeBinPath packages}" ];
        Type = "simple";
        ExecStart = "${lib.getExe cfg.package} --cfg ${file}";
      };
    };

in
{
  options.nazarick.service.kanata = {
    enable = lib.mkEnableOption "kanata";
    package = lib.mkOption {
      type = lib.types.package;
      default = mypkgs.kanata;
      description = "The package for kanata";
    };
  };
  config = mkIf cfg.enable {
    home.packages = with mypkgs; [
      kanata
      tofiApp
    ];

    systemd.user.services = {
      "kanata-k65" = mkKanataService {
        name = "k65";
        file = ./k65.kbd;
      };
      "kanata-kone" = mkKanataService {
        name = "kone";
        file = ./kone.kbd;
      };
    };
  };
}
