{
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf types mkEnableOption;
  inherit (mylib) mkOpt;
  cfg = config.nazarick.workspace.user;
in
{
  options.nazarick.workspace.user = {
    enable = mkEnableOption "Default User";
    name = mkOpt types.str "darkkronicle" "The (lowercase) name for the user.";
    fullName = mkOpt types.str "DarkKronicle" "The name for the user.";
    # TODO: nordvpn should be done in nordvpn
    extraGroups = mkOpt (types.listOf types.str) [
      "wheel"
      "nordvpn"
      "plugdev"
    ] "Groups for the user to be assigned.";
    extraOptions = mkOpt types.attrs { } (lib.mdDoc "Extra options for users.users.");
  };
  config = mkIf cfg.enable {
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