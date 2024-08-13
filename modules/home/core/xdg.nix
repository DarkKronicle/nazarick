{
  lib,
  config,
  pkgs,
  mylib,
  inputs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.core.xdg;

  browserAssociations = [
    "application/pdf"
    "application/rdf+xml"
    "application/rss+xml"
    "application/xhtml+xml"
    "application/xhtml_xml"
    "application/xml"
    "image/gif"
    "image/jpeg"
    "image/png"
    "image/webp"
    "text/html"
    "text/xml"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/ipfs"
    "x-scheme-handler/ipns"
    "default-web-browser"
  ];

  # https://github.com/spikespaz/dotfiles/blob/odyssey/users/jacob/mimeApps.nix
  flipAssocs =
    assocs:
    lib.pipe assocs [
      (lib.mapAttrsToList mapMimeListToXDGAttrs)
      lib.flatten
      lib.zipAttrs
    ];
  mapMimeListToXDGAttrs =
    prog:
    map (type: {
      "${type}" = "${prog}.desktop";
    });
in
{
  options.nazarick.core.xdg = {
    enable = mkEnableOption "Defaults";
  };

  config = mkIf cfg.enable {

    xdg.mimeApps =
      let
        associations = flipAssocs {
          "firefox" = browserAssociations;

          "org.kde.okular" = [
            "application/pdf"
            "application/epub"
            "application/djvu"
            "application/mobi"
            "application/vnd.kde.okular-archive"
            "application/x-gzpdf"
            "application/x-bzpdf"
            "application/x-wwf"
          ];

          "mpv" = [
            "application/ogg"
            "application/x-ogg"
            "application/mxf"
            "application/sdp"
            "application/smil"
            "application/x-smil"
            "application/streamingmedia"
            "application/x-streamingmedia"
            "application/vnd.rn-realmedia"
            "application/vnd.rn-realmedia-vbr"
            "audio/aac"
            "audio/x-aac"
            "audio/vnd.dolby.heaac.1"
            "audio/vnd.dolby.heaac.2"
            "audio/aiff"
            "audio/x-aiff"
            "audio/m4a"
            "audio/x-m4a"
            "application/x-extension-m4a"
            "audio/mp1"
            "audio/x-mp1"
            "audio/mp2"
            "audio/x-mp2"
            "audio/mp3"
            "audio/x-mp3"
            "audio/mpeg"
            "audio/mpeg2"
            "audio/mpeg3"
            "audio/mpegurl"
            "audio/x-mpegurl"
            "audio/mpg"
            "audio/x-mpg"
            "audio/rn-mpeg"
            "audio/musepack"
            "audio/x-musepack"
            "audio/ogg"
            "audio/scpls"
            "audio/x-scpls"
            "audio/vnd.rn-realaudio"
            "audio/wav"
            "audio/x-pn-wav"
            "audio/x-pn-windows-pcm"
            "audio/x-realaudio"
            "audio/x-pn-realaudio"
            "audio/x-ms-wma"
            "audio/x-pls"
            "audio/x-wav"
            "video/mpeg"
            "video/x-mpeg2"
            "video/x-mpeg3"
            "video/mp4v-es"
            "video/x-m4v"
            "video/mp4"
            "application/x-extension-mp4"
            "video/divx"
            "video/vnd.divx"
            "video/msvideo"
            "video/x-msvideo"
            "video/ogg"
            "video/quicktime"
            "video/vnd.rn-realvideo"
            "video/x-ms-afs"
            "video/x-ms-asf"
            "audio/x-ms-asf"
            "application/vnd.ms-asf"
            "video/x-ms-wmv"
            "video/x-ms-wmx"
            "video/x-ms-wvxvideo"
            "video/x-avi"
            "video/avi"
            "video/x-flic"
            "video/fli"
            "video/x-flc"
            "video/flv"
            "video/x-flv"
            "video/x-theora"
            "video/x-theora+ogg"
            "video/x-matroska"
            "video/mkv"
            "audio/x-matroska"
            "application/x-matroska"
            "video/webm"
            "audio/webm"
            "audio/vorbis"
            "audio/x-vorbis"
            "audio/x-vorbis+ogg"
            "video/x-ogm"
            "video/x-ogm+ogg"
            "application/x-ogm"
            "application/x-ogm-audio"
            "application/x-ogm-video"
            "application/x-shorten"
            "audio/x-shorten"
            "audio/x-ape"
            "audio/x-wavpack"
            "audio/x-tta"
            "audio/AMR"
            "audio/ac3"
            "audio/eac3"
            "audio/amr-wb"
            "video/mp2t"
            "audio/flac"
            "audio/mp4"
            "application/x-mpegurl"
            "video/vnd.mpegurl"
            "application/vnd.apple.mpegurl"
            "audio/x-pn-au"
            "video/3gp"
            "video/3gpp"
            "video/3gpp2"
            "audio/3gpp"
            "audio/3gpp2"
            "video/dv"
            "audio/dv"
            "audio/opus"
            "audio/vnd.dts"
            "audio/vnd.dts.hd"
            "audio/x-adpcm"
            "application/x-cue"
            "audio/m3u"
          ];

          "org.kde.ark" = [
            "application/zip"
            "application/gzip"
            "application/x-tar"
            "application/x-bzip"
            "application/x-bzip2"
            "application/x-7z-compressed"
            "application/xz"
            "application/x-targ"
            "application/x-compressed-targ"
            "application/x-bzip-compressed-targ"
            "application/x-tarzg"
            "application/x-xz-compressed-targ"
            "application/x-lzma-compressed-targ"
            "application/x-lzip-compressed-targ"
            "application/x-tzog"
            "application/x-lrzip-compressed-targ"
            "application/x-lz4-compressed-targ"
            "application/x-zstd-compressed-targ"
            "application/x-cd-imageg"
            "application/x-bcpiog"
            "application/x-cpiog"
            "application/x-cpio-compressedg"
            "application/x-sv4cpiog"
            "application/x-sv4crcg"
            "application/x-source-rpmg"
            "application/vnd.ms-cab-compressedg"
            "application/x-xarg"
            "application/x-iso9660-appimageg"
            "application/x-archiveg"
            "application/vnd.rarg"
            "application/x-rarg"
            "application/x-7z-compressedg"
            "application/zipg"
            "application/x-compressg"
            "application/gzipg"
            "application/x-bzipg"
            "application/x-lzmag"
            "application/x-xzg"
            "application/zstdg"
            "application/x-lhag"
          ];

          "mw-matlab" = [ "x-scheme-handler/mw-matlab" ];
          "mw-simulink" = [ "x-scheme-handler/mw-simulink" ];
          "mw-matlabconnector" = [ "x-scheme-handler/mw-matlabconnector" ];
        };
      in
      {
        enable = true;
        associations.added = associations;
        defaultApplications = associations;
        associations.removed = flipAssocs {
          # Bye bye brave
          "brave-browser" = browserAssociations;
        };
      };
  };
}
