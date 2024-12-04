# https://github.com/NixOS/nixpkgs/blob/57610d2f8f0937f39dbd72251e9614b1561942d8/nixos/modules/programs/firejail.nix
# Modified for home-manager
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.firejail;

  # Why do this weirdo nu stuff? Well because bash is super annoying and I really dislike bash
  # When passing in extra arguments like `--noexec=${HOME}`, that would get evaluated in the cat
  # body.
  nuScript = ''
    mkdir $"($env.out)/bin"
    mkdir $"($env.out)/share/applications"
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        command: value:
        let
          opts =
            if builtins.isAttrs value then
              value
            else
              {
                executable = value;
                desktop = null;
                profile = null;
                extraArgs = [ ];
              };
          args = lib.escapeShellArgs (
            opts.extraArgs
            ++ (lib.optional (opts.profile != null) "--profile=${builtins.toString opts.profile}")
          );
        in
        # nu
        ''
          r#'
          #! ${pkgs.runtimeShell} -e
          exec /run/wrappers/bin/firejail ${args} -- ${builtins.toString opts.executable} "$@"
          '# | str trim | save $"($env.out)/bin/${command}"
          chmod 0755 $"($env.out)/bin/${command}"
          ${lib.optionalString (opts.desktop != null) ''
            substitute ${opts.desktop} $"($env.out)/share/applications/(basename ${opts.desktop})" \
              --replace ${opts.executable} $"(env.out)/bin/${command}"
          ''}
        ''
      ) cfg.wrappedBinaries
    )}
  '';

  nuFile = pkgs.writeTextFile {
    name = "firejail.nu";
    text = nuScript;
  };

  wrappedBins =
    pkgs.runCommand "firejail-wrapped-binaries"
      {
        preferLocalBuild = true;
        allowSubstitutes = false;
        # take precedence over non-firejailed versions
        meta.priority = -1;
      }
      ''
        out=$out ${pkgs.nushell}/bin/nu ${nuFile}
      '';
in
{
  options.programs.firejail = {
    enable = lib.mkEnableOption "firejail, a sandboxing tool for Linux";

    wrappedBinaries = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.either lib.types.path (
          lib.types.submodule {
            options = {
              executable = lib.mkOption {
                type = lib.types.path;
                description = "Executable to run sandboxed";
                example = lib.literalExpression ''"''${lib.getBin pkgs.firefox}/bin/firefox"'';
              };
              desktop = lib.mkOption {
                type = lib.types.nullOr lib.types.path;
                default = null;
                description = ".desktop file to modify. Only necessary if it uses the absolute path to the executable.";
                example = lib.literalExpression ''"''${pkgs.firefox}/share/applications/firefox.desktop"'';
              };
              profile = lib.mkOption {
                type = lib.types.nullOr lib.types.path;
                default = null;
                description = "Profile to use";
                example = lib.literalExpression ''"''${pkgs.firejail}/etc/firejail/firefox.profile"'';
              };
              extraArgs = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                description = "Extra arguments to pass to firejail";
                example = [ "--private=~/.firejail_home" ];
              };
            };
          }
        )
      );
      default = { };
      example = lib.literalExpression ''
        {
          firefox = {
            executable = "''${lib.getBin pkgs.firefox}/bin/firefox";
            profile = "''${pkgs.firejail}/etc/firejail/firefox.profile";
          };
          mpv = {
            executable = "''${lib.getBin pkgs.mpv}/bin/mpv";
            profile = "''${pkgs.firejail}/etc/firejail/mpv.profile";
          };
        }
      '';
      description = ''
        Wrap the binaries in firejail and place them in the global path.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.firejail ] ++ [ (pkgs.hiPrio wrappedBins) ];
  };

  meta.maintainers = with lib.maintainers; [ peterhoeg ];
}
