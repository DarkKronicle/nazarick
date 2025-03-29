{ pkgs-unstable, ... }:

final: prev:

{
  nushellPlugins = pkgs-unstable.nushellPlugins // {
    # NOTE: had to fully copy this over because it's hard to override cargo hash
    skim = pkgs-unstable.rustPlatform.buildRustPackage rec {
      pname = "nu_plugin_skim";
      version = "0.13.0";

      src = pkgs-unstable.fetchFromGitHub {
        owner = "idanarye";
        repo = pname;
        tag = "v${version}";
        hash = "sha256-cVD/al5KF4y7oV3OwtfhWEytCD+IVmWdSlGub1w6UYk=";
      };

      useFetchCargoVendor = true;
      cargoHash = "sha256-CvBBBDi8AkSfCIcUyUH4e5DX5tija1KqE9z05lndNE4=";

      passthru = {
        tests.check =
          let
            nu = pkgs-unstable.lib.getExe pkgs-unstable.nushell;
            plugin = pkgs-unstable.lib.getExe pkgs-unstable.skim;
          in
          pkgs-unstable.runCommand "${pname}-test" { } ''
            touch $out
            ${nu} -n -c "plugin add --plugin-config $out ${plugin}"
            ${nu} -n -c "plugin use --plugin-config $out skim"
          '';
      };

      meta = with pkgs-unstable.lib; {
        description = "A nushell plugin that adds integrates the skim fuzzy finder";
        mainProgram = "nu_plugin_skim";
        homepage = "https://github.com/idanarye/nu_plugin_skim";
        license = licenses.mit;
        maintainers = with maintainers; [ aftix ];
        platforms = platforms.all;
      };
    };
  };
}
