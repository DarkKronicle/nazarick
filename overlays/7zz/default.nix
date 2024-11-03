{ ... }:

final: prev: {
  _7zz = prev._7zz.overrideAttrs (_: {
    makeFlags = [
      "CC=${prev.stdenv.cc.targetPrefix}cc"
      "CXX=${prev.stdenv.cc.targetPrefix}c++"
      "USE_ASM="
      "DISABLE_RAR_COMPRESS=true"
    ];
  });
}
