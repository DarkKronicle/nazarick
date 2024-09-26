{
  options,
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf types;
  inherit (mylib) mkBoolOpt mkOpt;
  cfg = config.impermanence;

  bootScript = ''
    mkdir /btrfs_tmp
    mount /dev/mapper/cryptroot /btrfs_tmp

    # Check root
    if [[ -e /btrfs_tmp/last_root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/last_root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/last_root "/btrfs_tmp/old_roots/$timestamp"
    fi

    if [[ -e /btrfs_tmp/@ ]]; then
        mv /btrfs_tmp/@ /btrfs_tmp/last_root
    fi

    # Check home
    if [[ -e /btrfs_tmp/last_home ]]; then
        mkdir -p /btrfs_tmp/old_homes
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/last_home)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/last_home "/btrfs_tmp/old_homes/$timestamp"
    fi

    if [[ -e /btrfs_tmp/@home ]]; then
        mv /btrfs_tmp/@home /btrfs_tmp/last_home
    fi

    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +${builtins.toString cfg.removeTmpFilesOlderThan}); do
        delete_subvolume_recursively "$i"
    done

    for i in $(find /btrfs_tmp/old_homes/ -maxdepth 1 -mtime +${builtins.toString cfg.removeTmpFilesOlderThan}); do
        delete_subvolume_recursively "$i"
    done

    btrfs subvolume create /btrfs_tmp/@
    btrfs subvolume create /btrfs_tmp/@home
    umount /btrfs_tmp
  '';
in
{
  options.impermanence = {
    enable = mkBoolOpt false "Enable impermanence";
    removeTmpFilesOlderThan = mkOpt types.int 14 "Number of days to keep old btrfs_tmp files";
  };

  options.environment = with types; {
    persist = mkOpt attrs { } "Files and directories to persist in the home";
    keepPersist = mkOpt attrs { } "Files and directories to persist in the home";
    transientPersist = mkOpt attrs { } "Files and directories to persist in the home";
    ephemeralPersist = mkOpt attrs { } "Files and directories to persist in the home";
  };

  config = mkIf cfg.enable {
    # This script does the actual wipe of the system
    # So if it doesn't run, the btrfs system effectively acts like a normal system

    # https://discourse.nixos.org/t/impermanence-vs-systemd-initrd-w-tpm-unlocking/25167/3
    boot.initrd.systemd.extraBin = {
      btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
      find = "${pkgs.findutils}/bin/find";
    };

    boot.initrd.systemd.services =
      if config.boot.initrd.systemd.enable then
        {
          rollback = {
            description = "Rollback BTRFS to a blank slate, while keeping old for a while";
            wantedBy = [ "initrd.target" ];
            after = [ "cryptsetup.target" ];
            before = [ "sysroot.mount" ];
            unitConfig.DefaultDependencies = "no";
            serviceConfig.Type = "oneshot";
            script = bootScript;
            path = with pkgs; [
              findutils
              btrfs-progs
              config.boot.initrd.systemd.package.util-linux
              coreutils
            ];
          };
        }
      else
        { };

    boot.initrd.postDeviceCommands =
      if config.boot.initrd.systemd.enable then "" else (lib.mkAfter bootScript);

    environment.persistence."/persist/system" = lib.mkAliasDefinitions options.environment.persist;
    environment.persistence."/persist/keep" = lib.mkAliasDefinitions options.environment.keepPersist;
    environment.persistence."/persist/transient" = lib.mkAliasDefinitions options.environment.transientPersist;
    environment.persistence."/persist/ephemeral" = lib.mkAliasDefinitions options.environment.ephemeralPersist;
  };
}
