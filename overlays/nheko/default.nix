{ ... }:
final: prev: {
  # for screen sharing pipewire needs to exist bc of gstreamer
  nheko = prev.nheko.overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs ++ [ final.pipewire ];
  });
}
