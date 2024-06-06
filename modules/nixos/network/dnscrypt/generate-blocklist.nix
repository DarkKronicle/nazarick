{
  blocklist,
  name,
  version,
  generate-domains-blocklist,
}:
{
  stdenv,
  python3,
  pkgs,
  ...
}:
stdenv.mkDerivation {
  inherit version;
  pname = "dnscrypt-blocklist-${name}";
  src = blocklist;
  dontUnpack = true;

  buildInputs = [ python3 ];
  buildPhase = ''
    runHook preBuild

    local content="file:"
    content+=$src

    echo $content >> blocklist.conf

    touch domains-time-restricted.txt
    touch domains-allowlist.txt

    mkdir -p $out/share/blocklist
    python ${generate-domains-blocklist} --config blocklist.conf -o $out/share/blocklist/${name}.txt

    runHook postBuild
  '';
}
