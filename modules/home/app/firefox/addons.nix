{ buildFirefoxXpiAddon, lib, ... }:
{
  better-canvas = buildFirefoxXpiAddon rec {
    pname = "better-canvas";
    version = "5.10.9";
    addonId = "{8927f234-4dd9-48b1-bf76-44a9e153eee0}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4255847/better_canvas-${version}.xpi";
    sha256 = "0a5m99nnhbha25a1pgyvh11nlg79pfmxk2az489il4f89vzd5jjw";
    meta = {
      homepage = "https://github.com/ksucpea/bettercanvas";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
    };
  };
  hide-youtube-shorts = buildFirefoxXpiAddon rec {
    pname = "hide-youtube-shorts";
    version = "1.7.4";
    addonId = "{88ebde3a-4581-4c6b-8019-2a05a9e3e938}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4222807/hide_youtube_shorts-${version}.xpi";
    sha256 = "083x96y69s297cygrc9xgqqlh1ks16mp57m2n9jmzh1nmxqk8nq2";
    meta = {
      homepage = "https://github.com/Vulpelo/hide-youtube-shorts";
      license = lib.licenses.gpl3Plus;
      platforms = lib.platforms.all;
    };
  };
}
