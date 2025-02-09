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
    version = "2025-02-09";
    src = fetchFromGitHub {
      owner = "dedukun";
      repo = "bookmarks.yazi";
      rev = "202e450b0088d3dde3c4a680f30cf9684acea1cc";
      hash = "sha256-cPvNEanJpcVd+9Xaenu8aDAVk62CqAWbOq/jApwfBVE=";
    }; # Patch with the actual binary
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/yazi/plugins/${name}.yazi
      cp -a $src/* $out/share/yazi/plugins/${name}.yazi

      runHook postInstall
    '';
  };
}
