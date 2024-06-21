{
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf types mkOption;
  cfg = config.nazarick.users;

  userType = types.submodule (
    { config, ... }:
    {
      options = {

        extraGroups = lib.mkOption {
          type = types.listOf types.string;
          default = [ ];
          description = "Extra groups for the user to be added to";
        };

        extraOptions = mkOption {
          type = types.attrs;
          default = { };
          description = "Extra options for users.users.";
        };

        shell = mkOption {
          type = types.nullOr (types.either types.shellPackage (types.passwdEntry types.path));
          default = pkgs.nushell;
          description = "Shell for the user";
        };

        uid = mkOption {
          type = types.int;
          description = "Set UID for the user";
        };

      };
    }
  );
in
{
  options.nazarick.users = {

    user = lib.mkOption {
      type = types.attrsOf userType;
      default = null;
      description = "User config";
    };

    mutableUsers = mkOption {
      type = types.bool;
      default = false;
      description = "If mutable users should be enabled";
    };

    extraGroups = mkOption {
      type = types.listOf types.str;
      description = "Groups for all users to be assigned";
    };

  };

  config = {
    users.mutableUsers = cfg.mutableUsers;
    users.users = lib.mkMerge (
      lib.mapAttrsToList (name: conf: {
        ${name} = {
          inherit name;
          extraGroups = conf.extraGroups ++ cfg.extraGroups;

          isNormalUser = true;
          initialHashedPassword =
            if cfg.mutableUsers then
              "$y$j9T$8CBOuUA/REWW2hhs5EKn71$vlcI/XYosme1hRLUgJsb.mlKpjsCkOhn/U.lrlcb2uC"
            else
              null; # >:\( :star: birb exists frfr

          uid = conf.uid;
          home = "/home/${name}";
          group = "users";
          shell = pkgs.nushell;
        } // conf.extraOptions;
      }) cfg.user
    );
  };

}
