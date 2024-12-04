{
  system,
  config,
  mypkgs,
  lib,
  pkgs,
  inputs,
  mylib,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;
  cfg = config.nazarick.core.nix;

  nixos-option-wrapped =
    let
      flake-compact = pkgs.fetchFromGitHub {
        owner = "edolstra";
        repo = "flake-compat";
        rev = "12c64ca55c1014cdc1b16ed5a804aa8576601ff2";
        sha256 = "sha256-hY8g6H2KFL8ownSiFeMOjwPC8P0ueXpCVEbxgda3pko=";
      };
      prefix = ''(import ${flake-compact} { src = /home/darkkronicle/nazarick; }).defaultNix.nixosConfigurations.\$(hostname)'';
    in
    pkgs.runCommandNoCC "nixos-option" { buildInputs = [ pkgs.makeWrapper ]; } ''
      makeWrapper ${pkgs.nixos-option}/bin/nixos-option $out/bin/nixos-option \
        --add-flags --config_expr \
        --add-flags "\"${prefix}.config\"" \
        --add-flags --options_expr \
        --add-flags "\"${prefix}.options\""
    '';
in
{
  options.nazarick.core.nix = {
    enable = mkBoolOpt false "Enable nix configuration.";
    update-registry = mkBoolOpt true "Update system wide nix registry";
  };
  config = mkIf cfg.enable {

    environment.systemPackages =
      (with pkgs; [
        nixfmt-rfc-style
        nix-output-monitor
        nurl
        nixos-option-wrapped
        nix-tree
      ])
      ++ [ mypkgs.naz ];

    # https://github.com/sioodmy/dotfiles/blob/dc9fce23ee4a58b6485f7572b850a7b2dcaf9bb7/system/core/nix.nix#L62-L68
    # Faster rebuilding
    documentation = {
      enable = true;
      doc.enable = false;
      man.enable = true;
      dev.enable = false;
    };

    # https://github.com/nix-community/srvos/blob/main/nixos/common/nix.nix
    # Make builds to be more likely killed than important services.
    # 100 is the default for user slices and 500 is systemd-coredumpd@
    # We rather want a build to be killed than our precious user sessions as builds can be easily restarted.
    systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = lib.mkDefault 250;

    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 14d --keep 15";
      };
    };

    nix = lib.mkMerge [
      {

        # https://github.com/sioodmy/dotfiles/blob/dc9fce23ee4a58b6485f7572b850a7b2dcaf9bb7/system/core/nix.nix#L83
        daemonCPUSchedPolicy = "idle";

        package = inputs.lix-module.packages.${system}.default;

        settings = {

          max-jobs = 2;

          experimental-features = [
            "nix-command"
            "flakes"
          ];

          builders-use-substitutes = true;
          warn-dirty = false;
          auto-optimise-store = true;

          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
            "https://cache.lix.systems"
          ];

          # Get names | from where user have "wheel" group
          trusted-users = lib.mapAttrsToList (name: _: name) (
            lib.attrsets.filterAttrs (
              name: cfg: builtins.elem "wheel" cfg.extraGroups
            ) config.nazarick.users.user
          );

          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
          ];
        };
      }
      (lib.mkIf cfg.update-registry {
        # FIXME:
        # This needs to be different bc of nixpkgs, if using stable it breaks things
        registry = lib.mapAttrs (_: v: { flake = v; }) inputs;
        nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
      })
    ];
  };
}
