{
  options,
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.nazarick) mkBoolOpt;
  cfg = config.nazarick.system.nix;
in
{
  options.nazarick.system.nix = {
    enable = mkBoolOpt false "Enable nix configuration.";
  };
  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      nixfmt-rfc-style
      nix-output-monitor
      nurl
      (writeScriptBin "nazarick" (builtins.readFile ./build.nu))
    ];

    # https://fosstodon.org/@lhf/110661879816118061
    system.activationScripts.diff = {
      supportsDryActivation = true;
      text = ''
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff \
        /run/current-system "$systemConfig"
      '';
    };

    # https://github.com/sioodmy/dotfiles/blob/dc9fce23ee4a58b6485f7572b850a7b2dcaf9bb7/system/core/nix.nix#L62-L68
    # Faster rebuilding
    documentation = {
      enable = true;
      doc.enable = false;
      man.enable = true;
      dev.enable = false;
    };

    nix = {

      # https://github.com/sioodmy/dotfiles/blob/dc9fce23ee4a58b6485f7572b850a7b2dcaf9bb7/system/core/nix.nix#L83
      registry = lib.mapAttrs (_: v: { flake = v; }) inputs;

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
      settings = {
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
          "https://devenv.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        ];
      };
    };
  };
}
