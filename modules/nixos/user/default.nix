{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.nazarick;
let
  inherit (lib) types mkEnableOption mkIf;
  cfg = config.nazarick.user;
in
{
  options.nazarick.user = with types; {
    enable = mkEnableOption "Default User";
    name = mkOpt str "darkkronicle" "The (lowercase) name for the user.";
    fullName = mkOpt str "DarkKronicle" "The name for the user.";
    # TODO: nordvpn should be done in nordvpn
    extraGroups = mkOpt (listOf str) [
      "wheel"
      "nordvpn"
      "plugdev"
    ] "Groups for the user to be assigned.";
    extraOptions = mkOpt attrs { } (mdDoc "Extra options for users.users.");
  };
  config = mkIf cfg.enable {
    environment.sessionVariables = {
      EDITOR = "nvim";
    };
    users.mutableUsers = false;
    sops.secrets."user/darkkronicle/password".neededForUsers = true;
    users.users.${cfg.name} = {
      isNormalUser = true;
      inherit (cfg) name extraGroups;

      home = "/home/${cfg.name}";
      group = "users";
      shell = pkgs.nushell;
      hashedPasswordFile = config.sops.secrets."user/darkkronicle/password".path;
    } // cfg.extraOptions;
  };
}
