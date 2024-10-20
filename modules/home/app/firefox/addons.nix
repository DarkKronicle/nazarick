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
  better-history-ng = buildFirefoxXpiAddon rec {
    pname = "better-history-ng";
    version = "2.1.0";
    addonId = "{058af685-fc17-47a4-991a-bab91a89533d}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4344210/better_history_ng-${version}.xpi";
    sha256 = "sha256-1Yn3fM27Ox3kxq6a9lcluqVOSnAtAMDqyYebw1UMZf8=";
    meta = {
      homepage = "https://github.com/Christoph-Wagner/firefox-better-history-ng";
      license = lib.licenses.unlicense;
      platforms = lib.platforms.all;
    };
  };
}
