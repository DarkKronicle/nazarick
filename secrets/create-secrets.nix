# Essentially lazy locking secrets
# They can be "faked" so the system still builds, just specific things need to be
# tweaked
{
  fake ? true,
  pkgs,
  inputs,
  system,
  ...
}:
let
  locked-info = builtins.fromJSON (builtins.readFile ./secrets.lock);
  git-info = builtins.fetchGit { inherit (locked-info) url rev; };
  lix = inputs.lix-module.packages.${system}.default;
  nu-cmd = ''let calced = (${lix}/bin/nix-hash --type sha256 "${git-info}" | str trim); if (not ($calced == ${locked-info.sha256})) { error make { msg: $"Differing hashes. Expected ${locked-info.sha256}, got ($calced)"  } }'';
  calculated-match = builtins.readFile (
    pkgs.runCommandNoCC "secrets-hash" { } ''${pkgs.nushell}/bin/nu -c '${nu-cmd}' > $out''
  );
  valid = (if fake then (true) else (calculated-match == ""));
in
{
  inherit fake valid;
  src = if fake then ./fake-secrets else git-info;
  message = if fake then "" else "Expected ${locked-info.sha256}, got ${calculated-match}";
}
