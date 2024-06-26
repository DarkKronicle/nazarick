{ lib, ... }:

rec {
  # https://github.com/ryan4yin/nix-config/blob/82dccbdecaf73835153a6470c1792d397d2881fa/lib/default.nix#L13
  # use path relative to the root of the project
  relativeToRoot = lib.path.append ../.;
  scanPaths =
    path:
    builtins.map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          path: _type:
          (_type == "directory") # include directories
          || (
            (path != "default.nix") # ignore default.nix
            && (lib.strings.hasSuffix ".nix" path) # include .nix files
          )
        ) (builtins.readDir path)
      )
    );

  writeScript =
    pkgs: name: content:
    pkgs.writeTextFile {
      inherit name;
      executable = true;
      text = content;
      destination = "/bin/${name}";
      meta.mainProgram = name;
    };

  forEachUser =
    config: function: (lib.mapAttrsToList (name: _: function name)) config.nazarick.users.user;

  forEachUserAttr =
    config: function: (lib.mapAttrsToList (name: cfg: function name cfg)) config.nazarick.users.user;

  nixosSystem = import ./nixosSystem.nix;

}
// (import ./module { inherit lib; })
// (import ./package { inherit lib; })
// (import ./package/mkwindowsapp { inherit lib; })
// (import ./certs.nix { inherit lib; })
