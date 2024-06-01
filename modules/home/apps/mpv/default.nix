{
  lib,
  mylib,
  config,
  pkgs,
  mypkgs,
  inputs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.apps.mpv;

  cflPrediction = pkgs.fetchFromGitHub {
    owner = "Artoriuz";
    repo = "glsl-chroma-from-luma-prediction";
    rev = "37a449a94f8c532b4ed06822ea8b0398f4209737";
    hash = "sha256-3Q8aDgdsKnJhd3fmEoJMTDoAkA5s2g1ve9SB1HKAB1U=";
  };

  anime4k = pkgs.fetchzip {
    url = "https://github.com/bloc97/Anime4K/releases/download/v4.0.1/Anime4K_v4.0.zip";
    stripRoot = false;
    hash = "sha256-9B6U+KEVlhUIIOrDauIN3aVUjZ/gQHjFArS4uf/BpaM=";
  };
in
{
  options.nazarick.apps.mpv = {
    enable = mkEnableOption "mpv";
  };

  # https://iamscum.wordpress.com/guides/videoplayback-guide/mpv-conf/
  # A lot of this is based on this guide above.
  # NOTICE: I know anime 4k isn't a true upscaler. But I like it for low-bitrate anime :)
  config = mkIf cfg.enable {

    programs.mpv = {
      enable = true;
      package = pkgs.wrapMpv pkgs.mpv-unwrapped {
        youtubeSupport = true;
        # Useful scripts. Not my entire config, should probably do that
        scripts =
          (with pkgs; [
            mpvScripts.mpris
            mpvScripts.autoload
            mpvScripts.uosc
            mpvScripts.thumbfast
            (pkgs.callPackage ./leader.nix { })
          ])
          ++ (with mypkgs; [
            mpv-animecards
            mpv-skipsilence
          ]);
      };

      bindings = {
        "h" = "cycle deband";
        "F5" = ''script-message-to skipsilence enable no-osd; apply-profile skipsilence-default; show-text "skipsilence profile: default"'';
        "Alt+l" = "add sub-scale +0.1";
        "Alt+h" = "add sub-scale -0.1";
        "Alt+j" = "add sub-pos +1";
        "Alt+k" = "add sub-pos -1";
      };

      config = {
        profile = "gpu-hq";
        gpu-api = "vulkan";
        vo = "gpu-next";
        keep-open = "yes";
        force-window = "immediate";
        autofit = "70%";
        force-seekable = "yes";
        screenshot-template = "%F - [%P] (%#01n)";
        save-position-on-quit = "yes";
        reset-on-next-file = "audio-delay,mute,pause,speed,sub-delay,video-aspect-override,video-pan-x,video-pan-y,video-rotate,video-zoom,volume";
        input-ipc-server = "/tmp/kamite-mpvsocket";
        # for uosc
        osd-bar = "no";
        border = "no";

        # ytdl

        ytdl-format = ''bestvideo[height<=?1080]+bestaudio/best'';
        ytdl-raw-options = ''write-sub=,write-auto-sub=,sub-langs="ja,jp,jpn,en.*"'';

        scale = "ewa_lanczos";
        scale-blur = 0.981251;
        dscale = "mitchell";
        cscale = "spline36";

        dither-depth = "auto";
        dither = "fruit";

        deband = "yes";
        deband-iterations = 4;
        deband-threshold = 48;
        deband-range = 24;
        deband-grain = 16;

        scale-antiring = 0.7;
        dscale-antiring = 0.7;
        cscale-antiring = 0.7;

        # Audio normalization, can be weird
        # af=acompressor
        # af=lavfi=[loudnorm=i=-14.0:lra=13.0:tp=-1.0]

        # Make audio louder
        af = "lavfi=[acompressor=4]";

        #
        # Subtitle settings
        # 
        # Show subs, guess on what subs, prioritize japanese, try to fix timings, make subs a bit bigger
        sub-visibility = "yes";
        sub-auto = "fuzzy";
        alang = "jpn,ja,jp,eng,en";
        slang = "jpn,ja,jp,eng,en";
        audio-file-auto = "fuzzy";
        sub-fix-timing = "yes";
        autofit-larger = "100%x100%";
        geometry = "50%:50%";

        # Sub appearance
        sub-font = "'Noto Sans CJK JP'";
        sub-border-size = 3;
        sub-back-color = "#88000000";
        # sub-shadow-offset="1"
        sub-font-size = 75;
        sub-scale-by-window = "no";
        secondary-sub-visibility = "no";

        # Oh my gosh please, .ass stop taking over my fonts.
        sub-ass-scale-with-window = "no";
        sub-ass-override = "yes";
        sub-ass = "no";
      };
      profiles = {
        "no-shaders" = {
          glsl-shaders-clr = "";
        };
        "grain-shaders" = {
          glsl-shaders-toggle = [ "${./grain/noise_static_luma.hook}" ];
        };
        "skipsilence-default" = {
          script-opts-append = [
            "skipsilence-ramp_constant=1.5"
            "skipsilence-ramp_factor=1.15"
            "skipsilence-ramp_exponent=1.2"
            "skipsilence-speed_max=4"
            "skipsilence-speed_updateinterval=0.2"
            "skipsilence-startdelay=0.05"
          ];
        };
        "interpolate-shaders" = {
          glsl-shaders-toggle = [ "${cflPrediction}/CfL_Prediction.glsl" ];
        };
        "interpolate" = {
          display-fps-override = 60;
          video-sync = "display-resample";
          interpolation = "yes";
          tscale = "oversample";
        };
        "anime" = {
          deband-iterations = 4;
          deband-threshold = 35;
          deband-range = 20;
          deband-grain = 5;
        };
        "anime4k-a-shaders" = {
          glsl-shaders-toggle = [
            "${anime4k}/Anime4K_Clamp_Highlights.glsl"
            "${anime4k}/Anime4K_Restore_CNN_M.glsl"
            "${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"
            "${anime4k}/Anime4K_AutoDownscalePre_x2.glsl"
            "${anime4k}/Anime4K_AutoDownscalePre_x4.glsl"
            "${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"
          ];
        };
      };
    };
  };
}
