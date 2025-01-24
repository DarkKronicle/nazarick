{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.nazarick.service.logrotate;
  username = config.home.username;

  fileContents = ''
      /home/${username}/.local/state/nvim/*log {
        weekly
        missingok
        rotate 4
        copytruncate
        compress
        compresscmd ${pkgs.zstd}/bin/zstd
        compressext .zst
        compressoptions -T0 --long
        uncompresscmd ${pkgs.zstd}/bin/unzstd
        size 5M
        minsize 1M
    }

    /home/${username}/.cache/nheko/nheko/*log {
        weekly
        missingok
        rotate 4
        copytruncate
        compress
        compresscmd ${pkgs.zstd}/bin/zstd
        compressext .zst
        compressoptions -T0 --long
        uncompresscmd ${pkgs.zstd}/bin/unzstd
        size 5M
        minsize 1M
    }

    /home/${username}/.cache/iamb/logs/iamb-* {
        weekly
        missingok
        rotate 4
        copytruncate
        compress
        compresscmd ${pkgs.zstd}/bin/zstd
        compressext .zst
        compressoptions -T0 --long
        uncompresscmd ${pkgs.zstd}/bin/unzstd
        size 5M
        minsize 1M
    }

    /home/${username}/.cache/nvim/*log {
        weekly
        missingok
        rotate 4
        copytruncate
        compress
        compresscmd ${pkgs.zstd}/bin/zstd
        compressext .zst
        compressoptions -T0 --long
        uncompresscmd ${pkgs.zstd}/bin/unzstd
        size 5M
        minsize 1M
    }

    /home/${username}/.cache/nvim/codeium/*log {
        weekly
        missingok
        rotate 4
        copytruncate
        compress
        compresscmd ${pkgs.zstd}/bin/zstd
        compressext .zst
        compressoptions -T0 --long
        uncompresscmd ${pkgs.zstd}/bin/unzstd
        size 5M
        minsize 1M
    }

    /home/${username}/.local/state/PrismLauncher/logs/*log {
        weekly
        missingok
        rotate 4
        copytruncate
        compress
        compresscmd ${pkgs.zstd}/bin/zstd
        compressext .zst
        compressoptions -T0 --long
        uncompresscmd ${pkgs.zstd}/bin/unzstd
        size 5M
        minsize 1M
    }

  '';

  file = pkgs.writeTextFile {
    name = "logrotate.conf";
    text = fileContents;
  };

  nuFile = pkgs.writeTextFile {
    name = "logrotate.nu";
    text = # nu
      ''
        def main [] {
          mkdir /home/${username}/.local/share/logrotate/
          ${pkgs.logrotate}/bin/logrotate -s '/home/${username}/.local/share/logrotate/status' ${file};
        }
      '';
  };
in
{
  options.nazarick.service.logrotate = {
    enable = lib.mkEnableOption "logrotate";
  };

  config = lib.mkIf cfg.enable {

    systemd.user.services."logrotate" = {
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.nushell}/bin/nu ${nuFile}";
      };
    };

    systemd.user.timers."logrotate" = {
      Install = {
        WantedBy = [ "default.target" ];
      };

      Timer = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "5m";
      };
    };

  };

}
