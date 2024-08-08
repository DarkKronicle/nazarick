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
        mkdir -p $(dirname "$scriptNuSource")

        cp "${modifiedSource}" "$scriptTarget"

        ${
          if script.useAll then
            ''
              echo "use $scriptTarget *" >> $scriptNuSource
            ''
          else
            ''
              echo "use $scriptTarget" >> $scriptNuSource
            ''
        }

        ${
          if script.createBin then
            ''
              mkdir -p $(dirname "$scriptBin")
              cat <<EOT >> $scriptUnwrappedBin
              #!/usr/bin/env sh 
              nu -c "use $scriptTarget; \$*"
              EOT

              chmod +x $scriptUnwrappedBin

              makeWrapper $scriptUnwrappedBin $scriptBin --prefix PATH : ${
                lib.makeBinPath (script.dependencies ++ [ pkgs.nushell ])
              }
            ''
          else
            ""
        }

        runHook postBuild
      '';
      # The above bin file won't work with " in arguments

    };
  createScript =
    packageFile:
    let
      scriptLoaded = {
        useAll = false;
        createBin = true;
        dependencies = [ ];
      } // (import packageFile extra-inputs);
    in
    {
      name = scriptLoaded.name;
      value = nuScriptToPkg scriptLoaded;
    };

in
lib.listToAttrs (lib.forEach scriptFiles (script: createScript script))
