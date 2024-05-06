{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  cfg = config.nazarick.tools.nushell;

  catppuccin-btop = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "btop";
    rev = "c6469190f2ecf25f017d6120bf4e050e6b1d17af";
    sha256 = "sha256-jodJl4f2T9ViNqsY9fk8IV62CrpC5hy7WK3aRpu70Cs=";
  };
in
{
  options.nazarick.tools.nushell = {
    enable = mkEnableOption "Nushell";
  };

  options.nazarick.home = with lib.types; {
    environmentVariables = lib.nazarick.mkOpt (attrsOf str) { } "Environment variables";
  };

  config = mkIf cfg.enable {

    systemd.user.services = {
      nushell-history = {
        Unit = {
          Description = "Make atuin history nushell history";
        };

        Service = {
          Type = "oneshot";
          ExecStart = ''${pkgs.nushell}/bin/nu -c "ATUIN_SESSION='blank' ${pkgs.atuin}/bin/atuin history list --cmd-only | split row '\n' | reverse | uniq | reverse | save -f /home/darkkronicle/.config/nushell/history.txt"'';
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };

    home.file.".config/starship.toml".source = ./starship/starship.toml;

    home.file.".config/nushell" = {
      source = ./config;
      recursive = true;
    };

    services.gpg-agent = {
      enable = true;
      enableNushellIntegration = true;
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-curses;
    };

    home.file.".config/btop/themes" = {
      source = "${catppuccin-btop}/themes";
      recursive = true;
    };

    services.pueue.enable = true;
    programs = {
      nushell = {
        enable = true;
        configFile.text = builtins.readFile ./config.nu;
        envFile.text = builtins.readFile ./env.nu;
        environmentVariables = config.nazarick.home.environmentVariables;
      };

      direnv = {
        enable = true;
        enableNushellIntegration = true;
        nix-direnv.enable = true;
      };

      starship = {
        enable = true;
        enableNushellIntegration = true;
      };

      atuin = {
        enable = true;
        package = pkgs.atuin;
        enableNushellIntegration = true;
        settings = {
          inline_height = 15;
          style = "compact";
        };
        flags = [ "--disable-up-arrow" ];
      };

      nix-index.enable = true;

      zoxide = {
        enable = true;
        enableNushellIntegration = true;
      };

      eza = {
        enable = true;
      };

      tealdeer = {
        enable = true;
        settings = {
          display = {
            compact = true;
          };
          updates = {
            auto_update = true;
            auto_update_interval_hours = 1440;
          };
        };
      };

      carapace = {
        enable = true;
        enableNushellIntegration = true;
      };

      btop = {
        enable = true;
        package = (
          pkgs.btop.overrideAttrs (oldAttrs: {
            nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.addOpenGLRunpath ];
            postFixup = ''
              addOpenGLRunpath $out/bin/btop
            '';
          })
        );
        settings = {
          color_theme = "catppuccin_mocha";
          theme_background = false;
          vim_keys = true;
          # cpu_single_graph = true;
          temp_scale = "fahrenheit";
          swap_disk = false;
          disks_filter = "/ /boot"; # /home, /nix, / are only subvolumes
        };
      };
    };
  };
}
