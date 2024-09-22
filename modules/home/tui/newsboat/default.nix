{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nazarick.tui.newsboat;

  catppuccin = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "newsboat";
    rev = "be3d0ee1ba0fc26baf7a47c2aa7032b7541deb0f";
    hash = "sha256-czvR3bVZ0NfBmuu0JixalS7B1vf1uEGSTSUVVTclKxI=";
  };
in
{
  options.nazarick.tui.newsboat = {
    enable = lib.mkEnableOption "newsboat";
  };

  config = lib.mkIf cfg.enable {
    programs.newsboat = {
      enable = true;
      browser = ''"w3m %u"'';
      autoReload = true;
      extraConfig = ''
        include ${catppuccin}/themes/dark

        suppress-first-reload yes

        bind-key j next
        bind-key k prev
        bind-key J next-feed
        bind-key K prev-feed
        bind-key j down article
        bind-key k up article
        bind-key J next article
        bind-key K prev article
        bind-key l open
        bind-key h quit

        unbind-key ENTER
        unbind-key o

        bind-key o open
        bind-key ENTER open-in-browser-and-mark-read

        macro y set browser "mpv %u" ; open-in-browser-and-mark-read ; set browser "w3m %u"
        macro f set browser "firefox %u" ; open-in-browser-and-mark-read ; set browser "w3m %u"
      '';
    };
  };

}
