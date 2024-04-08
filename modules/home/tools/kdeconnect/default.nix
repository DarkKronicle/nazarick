{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.nazarick.tools.kdeconnect;
in
{
  options.nazarick.tools.kdeconnect = {
    enable = mkEnableOption "KDE-Connect";
  };

  config = mkIf cfg.enable {
    # https://invent.kde.org/plasma/xdg-desktop-portal-kde/-/merge_requests/144
    # :(
    # this problem actually goes pretty deep into how nix works. When scanning for startup 
    # scripts it will create a new systemd service. Setting kdeconnect enabled in home manager
    # also makes it start as a systemd service.
    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/config/xdg/autostart.nix

    # so the fix is to *hopefully* properly symlink this. Added Hidden=true to overwite it
    # UPDATE: Fix does not work :(

    home.packages = [ pkgs.kdePackages.kdeconnect-kde ];

    home.file.".config/autostart/kdeconnect.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Exec=${pkgs.kdePackages.kdeconnect-kde}/libexec/kdeconnectd
      X-KDE-StartupNotify=false
      X-KDE-autostart-phase=1
      X-GNOME-Autostart-enabled=true
      NoDisplay=true
      Icon=kdeconnect
      Hidden=true

      Name=KDE Connect
      Name[ar]=كِيدِي المتّصل
      Name[az]=KDE Connect
      Name[bg]=KDE Connect
      Name[bs]=Konekcija KDE
      Name[ca]=KDE Connect
      Name[ca@valencia]=KDE Connect
      Name[cs]=KDE Connect
      Name[da]=KDE Connect
      Name[de]=KDE Connect
      Name[el]=KDE Connect
      Name[en_GB]=KDE Connect
      Name[eo]=KDE Konekti
      Name[es]=KDE Connect
      Name[et]=KDE Connect
      Name[eu]=KDE Connect
      Name[fi]=KDE Connect
      Name[fr]=KDE Connect
      Name[gl]=KDE Connect
      Name[he]=KDE Connect
      Name[hu]=KDE Connect
      Name[ia]=KDE Connect
      Name[id]=KDE Connect
      Name[ie]=KDE Connect
      Name[is]=KDE Connect
      Name[it]=KDE Connect
      Name[ja]=KDE Connect
      Name[ka]=KDE Connect
      Name[ko]=KDE Connect
      Name[lt]=KDE Connect
      Name[ml]=കെ.ഡി.ഇ കണക്റ്റ്
      Name[nl]=KDE Connect
      Name[nn]=KDE Connect
      Name[pl]=KDE Connect
      Name[pt]=KDE Connect
      Name[pt_BR]=KDE Connect
      Name[ro]=KDE Connect
      Name[ru]=KDE Connect
      Name[sk]=KDE Connect
      Name[sl]=KDE Connect
      Name[sr]=КДЕ‑конекција
      Name[sr@ijekavian]=КДЕ‑конекција
      Name[sr@ijekavianlatin]=KDE‑konekcija
      Name[sr@latin]=KDE‑konekcija
      Name[sv]=KDE-anslut
      Name[ta]=கே.டீ.யீ. கனெக்ட்
      Name[tr]=KDE Bağlan
      Name[uk]=З’єднання KDE
      Name[x-test]=xxKDE Connectxx
      Name[zh_CN]=KDE Connect
      Name[zh_TW]=KDE 連線
    '';
  };
}
