{ ... }:
final: prev: {
  tlp = prev.tlp.overrideAttrs (old: {
    makeFlags = (old.makeFlags or [ ]) ++ [
      "TLP_ULIB=/lib/udev"
      "TLP_NMDSP=/lib/NetworkManager/dispatcher.d"
      "TLP_SYSD=/lib/systemd/system"
      "TLP_SDSL=/lib/systemd/system-sleep"
      "TLP_ELOD=/lib/elogind/system-sleep"
      "TLP_CONFDPR=/share/tlp/deprecated.conf"
      "TLP_FISHCPL=/share/fish/vendor_completions.d"
      "TLP_ZSHCPL=/share/zsh/site-functions"
    ];
  });
}
