{
  inputs,
  lib,
  mylib,
  system,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  mysecrets,
  ...
}:
let
  mkNuList =
    items: "[ ${lib.concatStringsSep "," (lib.forEach items (content: "\"${content}\" "))} ]";

  extra-inputs = {
    inherit
      inputs
      lib
      system
      pkgs
      pkgs-stable
      pkgs-unstable
      mysecrets
      mylib
      ;
  };
  scriptFiles = mylib.scanPaths ./.;
  nuScriptToPkg =
    script:
    let
      prepend = mkNuList (lib.forEach script.dependencies (pkg: "${lib.getBin pkg}/bin"));

      modifiedSource = pkgs.substitute {
        src = script.source;
        substitutions = [
          "--replace"
          "@NIX_PATH_PREPEND@"
          prepend
        ];
      };

    in
    pkgs.stdenvNoCC.mkDerivation {
      name = script.name;
      dontUnpack = true;
      enableParallelBuilding = true;
      passAsFile = "scriptContent";
      nativeBuildInputs = [ pkgs.makeWrapper ];
      buildPhase = ''
        runHook preBuild

        scriptTarget=$out/share/nushell/modules/${script.name}.nu
        scriptUnwrappedBin=$out/bin/.${script.name}-unwrapped
        scriptBin=$out/bin/${script.name}
        scriptNuSource=$out/share/nushell/vendor/autoload/${script.name}

        mkdir -p $(dirname "$scriptTarget")
        mkdir -p $(dirname "$scriptBin")
        mkdir -p $(dirname "$scriptNuSource")

        cp "${modifiedSource}" "$scriptTarget"

        echo "use $scriptTarget" >> $scriptNuSource

        cat <<EOT >> $scriptUnwrappedBin
        #!/usr/bin/env sh 
        nu -c "$scriptTarget \$*"
        EOT

        chmod +x $scriptUnwrappedBin

        makeWrapper $scriptUnwrappedBin $scriptBin --prefix PATH : ${
          lib.makeBinPath (script.dependencies ++ [ pkgs.nushell ])
        }

        runHook postBuild
      '';
      # The above bin file won't work with " in arguments

    };
  createScript =
    packageFile:
    let
      scriptLoaded = import packageFile extra-inputs;
    in
    {
      name = scriptLoaded.name;
      value = nuScriptToPkg scriptLoaded;
    };

in
lib.listToAttrs (lib.forEach scriptFiles (script: createScript script))
