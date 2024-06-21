# Define
{
  lib,
  mylib,
  config,
  pkgs,
  ...
}:
let
  forEachUser = mylib.forEachUser config;
  systemctlForUsersNu = cmd: ''
    let users = ${pkgs.coreutils}/bin/who -q | split row (char newline) | drop 1
    ${lib.concatStringsSep "\n" (
      forEachUser (user: ''
        if ($users | find -r '^${user}$' | is-not-empty) {
          systemctl --user -M ${user}@.host ${cmd}
        }
      '')
    )}
  '';
in
{
  config = {
    systemd.user.targets = {
      "sleep" = {
        # https://unix.stackexchange.com/a/412352
        name = "sleep.target";
        description = "Sleep target for users";
        requires = [ "default.target" ];
        after = [ "default.target" ];
        # Nothing in install, just an orphaned service essentially
      };
    };

    systemd.services = {
      user-sleep-target = {
        serviceConfig = {
          Type = "oneshot"; # Just execute the script
          RemainAfterExit = true; # After executing, stay up
        };

        wantedBy = [ "sleep.target" ]; # sleep.target signals to start this service
        partOf = [ "sleep.target" ]; # if sleep.target is ever stopped or restarted, so will this

        script = ''${pkgs.nushell}/bin/nu ${
          pkgs.writeTextFile {
            name = "sleep-launch-start.nu";
            text = systemctlForUsersNu "start sleep.target";
          }
        }'';
        preStop = ''${pkgs.nushell}/bin/nu ${
          pkgs.writeTextFile {
            name = "sleep-launch-stop.nu";
            text = systemctlForUsersNu "stop sleep.target";
          }
        }'';
      };
    };

  };

}
