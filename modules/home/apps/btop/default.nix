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

  cfg = config.nazarick.apps.btop;

  catppuccin-btop = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "btop";
    rev = "c6469190f2ecf25f017d6120bf4e050e6b1d17af";
    sha256 = "sha256-jodJl4f2T9ViNqsY9fk8IV62CrpC5hy7WK3aRpu70Cs=";
  };
in
{
  options.nazarick.apps.btop = {
    enable = mkEnableOption "btop";
  };

  config = mkIf cfg.enable {
    xdg.configFile."btop/themes" = {
      enable = true;
      source = "${catppuccin-btop}/themes";
      recursive = true;
    };

    programs.btop = {
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
}
