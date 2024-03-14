{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.nazarick;
let
  cfg = config.nazarick.user;
in
{
  options.nazarick.user = with types; {
    name = mkOpt str "darkkronicle" "The (lowercase) name for the user.";
    fullName = mkOpt str "DarkKronicle" "The name for the user.";
    initialPassword = mkOpt str "password" "Initial password for the user.";
    # TODO: nordvpn should be done in nordvpn
    extraGroups = mkOpt (listOf str) [
      "wheel"
      "nordvpn"
    ] "Groups for the user to be assigned.";
    extraOptions = mkOpt attrs { } (mdDoc "Extra options for users.users.");
  };
  config = {
    environment.variables.EDITOR = "steam-run nvim";
    users.users.${cfg.name} = {
      isNormalUser = true;
      inherit (cfg) name initialPassword extraGroups;

      home = "/home/${cfg.name}";
      group = "users";
      shell = pkgs.nushell;
    } // cfg.extraOptions;
  };
}
