{ config, lib, ... }:
let
  cfg = config.nazarick.cli.zk;
in
{
  options.nazarick.cli.zk = {
    enable = lib.mkEnableOption "zk config";
    notebookDir = lib.mkOption {
      type = lib.types.str;
      description = "Directory for ZK notebook";
    };

  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      "ZK_NOTEBOOK_DIR" = cfg.notebookDir;
    };

    programs.zk = {
      enable = true;
      settings = {
        notebook.dir = "${cfg.notebookDir}";
        note = {
          id-charset = "hex";
          id-length = 8;
          id-case = "lower";
        };
        tool = {
          shell = "/run/current-system/sw/bin/bash";
        };
      };
    };
  };

}
