{ ... }:
final: prev: {
  nh = prev.nh.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [ ./nodev.patch ];
  });
}
