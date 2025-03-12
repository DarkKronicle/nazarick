{ pkgs-unstable, ... }:

final: prev:

{
  tomb =
    let
      tomb = pkgs-unstable.tomb.override { pinentry = prev.pinentry-gnome3; };

      extras-kdf = pkgs-unstable.stdenv.mkDerivation {
        pname = "tomb-extras-kdf-keys";
        version = pkgs-unstable.tomb.version;

        src = "${pkgs-unstable.tomb.src}/extras/kdf-keys";

        nativeBuildInputs = with pkgs-unstable; [
          libgcrypt
        ];

        installPhase = ''
          install -Dm755 tomb-kdb-pbkdf2 $out/bin/tomb-kdb-pbkdf2
          install -Dm755 tomb-kdb-pbkdf2-getiter $out/bin/tomb-kdb-pbkdf2-getiter
          install -Dm755 tomb-kdb-pbkdf2-gensalt $out/bin/tomb-kdb-pbkdf2-gensalt
        '';
      };
    in
    pkgs-unstable.symlinkJoin {
      inherit (tomb) name version;
      paths = [ tomb ];
      buildInputs = [ pkgs-unstable.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/tomb --prefix PATH : ${pkgs-unstable.lib.makeBinPath [ extras-kdf ]}
      '';
    };
}
