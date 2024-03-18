{
  pkgs,
  fetchurl,
  stdenv,
  lib,
  buildFHSEnv,
  appimageTools,
  writeShellScript,
  anki,
  undmg,
  zstd,
  commandLineArgs ? [ ],
}:
# https://github.com/NixOS/nixpkgs/blob/592047fc9e4f7b74a4dc85d1b9f5243dfe4899e3/pkgs/games/anki/bin.nix#L46
# nixpkgs is outdated

let
  pname = "anki-bin";
  # Update hashes for both Linux and Darwin!
  version = "24.04rc1";

  sources = {
    linux = fetchurl {
      url = "https://github.com/ankitects/anki/releases/download/${version}/anki-24.04-linux-qt6.tar.zst";
      sha256 = "sha256-yx/3P6WTgncQ3s5YNgqpnK2thkNDU07vIkfgDnz1mCM=";
    };
  };

  unpacked = stdenv.mkDerivation {
    inherit pname version;

    nativeBuildInputs = [ zstd ];
    buildInputs = [ zstd ];
    src = sources.linux;

    installPhase = ''
      runHook preInstall

      xdg-mime () {
        echo Stubbed!
      }
      export -f xdg-mime

      PREFIX=$out bash install.sh

      runHook postInstall
    '';
  };

  meta = with lib; {
    inherit (anki.meta)
      license
      homepage
      description
      longDescription
      ;
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    maintainers = with maintainers; [ mahmoudk1000 ];
  };

  passthru = {
    inherit sources;
  };

  fhsEnvAnki = buildFHSEnv (
    appimageTools.defaultFhsEnvArgs
    // {
      inherit pname version;
      name = null; # Appimage sets it to "appimage-env"

      # Dependencies of anki
      targetPkgs =
        pkgs:
        (with pkgs; [
          xorg.libxkbfile
          xcb-util-cursor-HEAD
          krb5
        ]);

      runScript = writeShellScript "anki-wrapper.sh" ''
        export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ zstd ]}:$LD_LIBRARY_PATH"
        export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib.outPath}/lib:$LD_LIBRARY_PATH"
          exec ${unpacked}/bin/anki ${lib.strings.escapeShellArgs commandLineArgs} "$@"
      '';

      extraInstallCommands = ''
        ln -s ${pname} $out/bin/anki

        mkdir -p $out/share
        cp -R ${unpacked}/share/applications \
          ${unpacked}/share/man \
          ${unpacked}/share/pixmaps \
          $out/share/
      '';

      inherit meta passthru;
    }
  );
in

if stdenv.isLinux then
  fhsEnvAnki
else
  stdenv.mkDerivation {
    inherit pname version passthru;

    src = if stdenv.isAarch64 then sources.darwin-aarch64 else sources.darwin-x86_64;

    nativeBuildInputs = [ undmg ];
    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out/Applications/
      cp -a Anki.app $out/Applications/
    '';

    inherit meta;
  }
