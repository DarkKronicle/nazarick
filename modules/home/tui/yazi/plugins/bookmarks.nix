{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}:
let
  name = "bookmarks";
in
{
  name = name;

  init_lua_text = ''
    require("bookmarks"):setup({
      last_directory = { enable = true, persist = true },
      persist = "vim",
      desc_format = "full",
      file_pick_mode = "hover",
      notify = {
        enable = false,
        timeout = 1,
        message = {
          new = "New bookmark '<key>' -> '<folder>'",
          delete = "Deleted bookmark in '<key>'",
          delete_all = "Deleted all bookmarks",
        },
      },
    })
  '';

  package = stdenv.mkDerivation {
    pname = name;
    version = "2025-03-02";
    src = fetchFromGitHub {
      owner = "dedukun";
      repo = "bookmarks.yazi";
      rev = "95b2c586f4a40da8b6a079ec9256058ad0292e47";
      hash = "sha256-cNgcTa8s+tTqAvF10fmd+o5PBludiidRua/dXArquZI=";
    }; # Patch with the actual binary
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/yazi/plugins/${name}.yazi
      cp -a $src/* $out/share/yazi/plugins/${name}.yazi

      runHook postInstall
    '';
  };
}
