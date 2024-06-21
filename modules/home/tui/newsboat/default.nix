{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nazarick.tui.newsboat;
  mdReader =
    let
      python3 = pkgs.python3.withPackages (ps: [ ps.readability-lxml ]);
      cache-dir = "~/.cache/newsboat";
    in
    ''
      #!/usr/bin/env nu

      def makemd [website: string] {
        let file = mktemp -t newsboat-XXXXXX
        let html = $file + ".html"
        let md = $file + ".md"
        (${python3}/bin/python3 -m readability.readability -u $website) | save -f $html
        ${pkgs.pandoc}/bin/pandoc $html --from html --to markdown_strict -o $md
        let content = (open $md)
        rm -fp $html
        rm -fp $md
        $content
      }

      def getfile [website: string] {
        mkdir ${cache-dir}
        let md5 = $website | hash md5
        let file = [ "${cache-dir}" ($md5 + ".md") ] | path join
        if (not ($file | path exists)) {
          (makemd $website) | save -f $file
        }
        return $file
      }

      def main [website: string] {
        let file = getfile $website
        ${pkgs.md-tui}/bin/mdt ($file | path expand)
      }
    '';

  mdExecutable = pkgs.writeTextFile {
    name = "md-browser.nu";
    executable = true;
    text = mdReader;
  };

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
      browser = ''"${mdExecutable} %u"'';
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

        macro y set browser "mpv %u" ; open-in-browser ; set browser "${mdExecutable} %u"
        macro f set browser "firefox %u" ; open-in-browser ; set browser "${mdExecutable} %u"
      '';
    };
  };

}
