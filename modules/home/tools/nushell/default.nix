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

  config = mkIf cfg.enable {
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
        # The overlay is applied here
        package = pkgs.nushell;
        configFile.text = builtins.readFile ./config.nu;
        envFile.text = builtins.readFile ./env.nu;
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

      bat = {
        enable = true;
        config = {
          theme = "catppuccin_mocha";
        };
        themes = {
          catppuccin_mocha = {
            src = pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/catppuccin/bat/2bafe4454d8db28491e9087ff3a1382c336e7d27/themes/Catppuccin%20Mocha.tmTheme";
              sha256 = "sha256-F4jRaI6KKFvj9GQTjwQFpROJXEVWs47HsTbDVy8px0Q=";
            };
          };
        };
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
