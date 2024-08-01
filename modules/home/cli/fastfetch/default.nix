{
  pkgs,
  options,
  config,
  lib,
  mylib,
  mypkgs,
  ...
}:
let

  cfg = config.nazarick.cli.fastfetch;
  icons = mypkgs.system-wallpapers.override {
    wallpapers = ./icons.yml;
    name = "fastfetch-icons";
  };

  fastFetchRandomIconContent = # nu
    ''
      #!/usr/bin/env nu
      def main [] {
        let path = '${icons}/share/wallpapers/fastfetch-icons'
        let choice = ls $path | shuffle | get 0.name
        # We icat because it is less jank, just have to make sure the images are all 200x200 px
        kitten icat --align=left $choice | fastfetch --raw - --logo-height 13 --logo-width 20
      }
    '';

  fastFetchRandom = mylib.writeScript pkgs "fastfetch-icon" fastFetchRandomIconContent;

in
{
  options.nazarick.cli.fastfetch = {
    enable = lib.mkEnableOption "fastfetch";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ fastFetchRandom ];

    programs.nushell.extraConfig = "fastfetch-icon";

    programs.fastfetch = {
      enable = true;
      settings = {
        logo = {
          # type = "kitty";
          # source = "file_here";
          width = 22;
          height = 11;
        };
        display = {
          separator = ": ";
          color = {
            title = "38;5;140";
            keys = "38;5;140";
          };
        };
        modules = [
          "title"
          "separator"
          "datetime"
          "uptime"
          "swap"
          "disk"
          "localip"
          "wifi"
          "battery"
        ];
      };
    };
  };

}
