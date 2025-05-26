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

  tofiApp =
    mylib.writeScript pkgs "tofi_app" # nu
      ''
        #!/usr/bin/env nu
          if ((do { pkill tofi } | complete).exit_code == 0) {
            return;
          }
          if ($env.DESKTOP_SESSION == "niri") {
            tofi-drun | niri msg action spawn -- ...($in | str trim | split row ' ')
          } else {
            tofi-drun | swaymsg exec -- ...($in | str trim | split row ' ')
          }
      '';

  packages = [
    pkgs.swayfx
    mypkgs.script-swu
    tofiApp
    pkgs.keepassxc
    pkgs.sway-overfocus
    pkgs.nushell
    pkgs.niri
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
        # TODO: needed?, dunno
        After = [ "graphical-sesion.target" ];
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
      default = pkgs.kanata-with-cmd;
      description = "The package for kanata";
    };
  };
  config = mkIf cfg.enable {
    home.packages = [
      pkgs.kanata-with-cmd
      tofiApp
    ];

    systemd.user.services = {
      "kanata-k65" =
        let
          nuScript = # nu
            ''
              let is_niri = ($env.DESKTOP_SESSION == "niri");
              let file = if ($is_niri) {
                  r####'${./k65-niri.kbd}'####
              } else {
                  r####'${./k65.kbd}'####
              }
              ${lib.getExe cfg.package} --cfg $file
            '';

          nuFile = pkgs.writeTextFile {
            name = "kanata-k65-start.nu";
            text = nuScript;
          };
        in
        {
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
          Unit = {
            Description = "Kanata remapper for k65 keyboard";
            Documentation = "https://github.com/jtroo/kanata";
          };

          Service = {
            Environment = [ "PATH=${lib.makeBinPath packages}" ];
            Type = "simple";
            ExecStart = "${lib.getExe pkgs.nushell} ${nuFile}";
          };
        };
      "kanata-kone" = mkKanataService {
        name = "kone";
        file = ./kone.kbd;
      };
    };
  };
}
