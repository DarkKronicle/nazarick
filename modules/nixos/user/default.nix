{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.nazarick; let
  cfg = config.nazarick.user;
in {
  options.nazarick.user = with types; {
    name = mkOpt str "darkkronicle" "The (lowercase) name for the user.";
    fullName = mkOpt str "DarkKronicle" "The name for the user.";
    initialPassword = mkOpt str "password" "Initial password for the user.";
    extraGroups = mkOpt (listOf str) [ "wheel" ] "Groups for the user to be assigned.";
    extraOptions = mkOpt attrs {} (mdDoc "Extra options for users.users.");
  };
  config = {
    users.users.${cfg.name} = {
      isNormalUser = true;
      inherit (cfg) name initialPassword extraGroups;

      home = "/home/${cfg.name}";
      group = "users";
    } // cfg.extraOptions;
  };
}
