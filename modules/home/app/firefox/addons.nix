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
  zotero = buildFirefoxXpiAddon rec {
    pname = "zotero";
    version = "5.0.159";
    addonId = "zotero@chnm.gmu.edu";
    url = "https://www.zotero.org/download/connector/dl?browser=firefox&version=${version}";
    sha256 = "sha256-CDedY6eYbwB99D7FPim1QsrD5B2nnahVGA5dmHTBgiQ=";
    meta = {
      homepage = "https://www.zotero.org/";
      license = lib.licenses.unlicense;
      platforms = lib.platforms.all;
    };
  };
}
