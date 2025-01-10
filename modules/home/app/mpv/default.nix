{
  lib,
  mylib,
  config,
  pkgs,
  mypkgs,
  inputs,
  mysecrets,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.app.mpv;

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
  options.nazarick.app.mpv = {
    enable = mkEnableOption "mpv";
  };

  # https://iamscum.wordpress.com/guides/videoplayback-guide/mpv-conf/
  # A lot of this is based on this guide above.
  # NOTICE: I know anime 4k isn't a true upscaler. But I like it for low-bitrate anime :)
  config = mkIf cfg.enable {

    programs.mpv = {
      enable = true;
      package = pkgs.mpv-unwrapped.wrapper {
        mpv = pkgs.mpv-unwrapped;
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
          ++ (with mypkgs; [ mpv-skipsilence ])
          ++ (lib.optionals (!mysecrets.fake) (with mypkgs; [ mpv-animecards ]));
      };

      bindings = {
        "h" = "cycle deband";
        "F5" =
          ''script-message-to skipsilence enable no-osd; apply-profile skipsilence-default; show-text "skipsilence profile: default"'';
        "F6" =
          ''script-message-to skipsilence enable no-osd; apply-profile skipsilence-patient; show-text "skipsilence profile: patient"'';
        "Alt+l" = "add sub-scale +0.1";
        "Alt+h" = "add sub-scale -0.1";
        "Alt+j" = "add sub-pos +1";
        "Alt+k" = "add sub-pos -1";
      };

      config =
        let
          sub-font = "Noto Sans CJK JP";
        in
        {
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
          inherit sub-font;
          sub-border-size = 3;
          sub-back-color = "#88000000";
          # sub-shadow-offset="1"
          sub-font-size = 75;
          sub-scale-by-window = "no";
          secondary-sub-visibility = "no";

          # Oh my gosh please, .ass stop taking over my fonts.
          # sub-ass-scale-with-window = "no";
          # sub-ass-override = "yes";
          # sub-ass = "no"; # Deprecated, use sub-ass-override = "strip";

          sub-ass-scale-with-window = "no";
          sub-ass-style-overrides-append =
            let
              # Overrides the default subs to look good. Will try not to touch
              # like signs, op or other specialty tracks

              # Spec:
              # http://www.tcax.org/docs/ass-specs.htm

              # I have to add more as time goes on :(
              # Just use mkvinfo, then mkvextract tracks

              dialogueStyles = [
                "Default"
                "DefaultTop"
                "Default Top"

                "Main"
                "MainTop"
                "Main Top"

                "Speech"
                "SpeechTop"
                "Speech Top"

                "Dialogue"
                "DialogueTop"
                "Dialogue Top"

                "Flashback"
                "FlashbackTop"
                "Flashback Top"
              ];

              italicStyles = [
                "Default Italic"
                "Default Italic Top"
                "DefaultItalic"
                "DefaultItalicTop"

                "Main Italic"
                "Main Italic Top"
                "MainItalic"
                "MainItalicTop"

                "Dialogue Italic"
                "DialogueItalic"
                "Dialogue Italic Top"
                "DialogueItalicTop"

                "FlashbackItalic"
                "Flashback Italic"
                "Flashback Italic Top"
                "FlashbackItalicTop"

                "Speech Italic"
                "SpeechItalic"
                "SpeechItalicTop"
                "Speech Italic Top"

                "Default Italics"
                "Default Italics Top"
                "DefaultItalics"
                "DefaultItalicsTop"

                "Main Italics"
                "Main Italics Top"
                "MainItalics"
                "MainItalicsTop"

                "Dialogue Italics"
                "DialogueItalics"
                "Dialogue Italics Top"
                "DialogueItalicsTop"

                "FlashbackItalics"
                "Flashback Italics"
                "Flashback Italics Top"
                "FlashbackItalicsTop"

                "Speech Italics"
                "SpeechItalics"
                "SpeechItalicsTop"
                "Speech Italics Top"
              ];

              boldStyles = [
                "Default Bold"
                "Default Bold Top"
                "DefaultBold"
                "DefaultBoldTop"

                "Main Bold"
                "Main Bold Top"
                "MainBold"
                "MainBoldTop"

                "Dialogue Bold"
                "Dialogue Bold Top"
                "DialogueBold"
                "DialogueBoldTop"

                "Flashback Bold"
                "Flashback Bold"
                "Flashback Bold Top"
                "FlashbackBoldTop"

                "Speech Bold"
                "SpeechBold"
                "SpeechBoldTop"
                "Speech Bold Top"
              ];

              italicBoldStyles = [
                "Default Italic Bold"
                "Default Italic Bold Top"
                "DefaultItalicBold"
                "DefaultItalicBoldTop"

                "Dialogue Italic Bold"
                "DialogueItalicBold"
                "Dialogue Italic Bold Top"
                "DialogueItalicBoldTop"

                "FlashbackItalicBold"
                "Flashback Italic Bold"
                "Flashback Italic Bold Top"
                "FlashbackItalicBoldTop"

                "Speech Italic Bold"
                "SpeechItalicBold"
                "SpeechItalicBoldTop"
                "Speech Italic Bold Top"

                "Default Bold Italic"
                "Default Bold Italic Top"
                "DefaultBoldItalic"
                "DefaultBoldItalicTop"

                "Dialogue Bold Italic"
                "Dialogue Bold Italic Top"
                "DialogueBoldItalic"
                "DialogueBoldItalicTop"

                "FlashbackBoldItalic"
                "Flashback Bold Italic"
                "Flashback Bold Italic Top"
                "FlashbackBoldItalicTop"

                "Speech Bold Italic"
                "SpeechBoldItalic"
                "SpeechBoldItalicTop"
                "Speech Bold Italic Top"

                "Default Italics Bold"
                "Default Italics Bold Top"
                "DefaultItalicsBold"
                "DefaultItalicsBoldTop"

                "Dialogue Italics Bold"
                "DialogueItalicsBold"
                "Dialogue Italics Bold Top"
                "DialogueItalicsBoldTop"

                "FlashbackItalicsBold"
                "Flashback Italics Bold"
                "Flashback Italics Bold Top"
                "FlashbackItalicsBoldTop"

                "Speech Italics Bold"
                "SpeechItalicsBold"
                "SpeechItalicsBoldTop"
                "Speech Italics Bold Top"

                "Default Bold Italics"
                "Default Bold Italics Top"
                "DefaultBoldItalics"
                "DefaultBoldItalicsTop"

                "Dialogue Bold Italics"
                "Dialogue Bold Italics Top"
                "DialogueBoldItalics"
                "DialogueBoldItalicsTop"

                "FlashbackBoldItalics"
                "Flashback Bold Italics"
                "Flashback Bold Italics Top"
                "FlashbackBoldItalicsTop"

                "Speech Bold Italics"
                "SpeechBoldItalics"
                "SpeechBoldItalicsTop"
                "Speech Bold Italics Top"
              ];

              altStyles = [
                "Alt"

                "Default - Alt"
                "Default Alt"
                "Alt Default"
                "DefaultAlt"

                "Main - Alt"
                "MainAlt"
                "Main Alt"
                "Alt Main"

                "Speech - Alt"
                "SpeechAlt"
                "Speech Alt"
                "Alt Speech"

                "Flashback - Alt"
                "FlashbackAlt"
                "Flashback Alt"
                "Alt Flashback"

                "Dialogue - Alt"
                "DialogueAlt"
                "Dialogue Alt"
                "Alt Dialogue"
              ];

              outlineThickness = "3";
              fontScale = "1.2";
              # I think the first is reverse alpha. Then it's BRG I think
              primaryColour = "00FFFFFF";
              backColour = "88000000";
              outlineColour = "00000000";
            in
            lib.flatten (
              (lib.forEach dialogueStyles (style: [
                "${style}.Borderstyle=4"
                "${style}.PrimayColour=&H${primaryColour}"
                "${style}.Fontname=${sub-font}"
                "${style}.BackColour=&H${backColour}"
                "${style}.OutlineColour=&H${outlineColour}"
                "${style}.Bold=0"
                "${style}.Italic=0"
                "${style}.Shadow=0"
                "${style}.Outline=${outlineThickness}"
                "${style}.ScaleX=${fontScale}"
                "${style}.ScaleY=${fontScale}"
              ]))
              ++ (lib.forEach italicStyles (style: [
                "${style}.Borderstyle=4"
                "${style}.BackColour=&H${backColour}"
                "${style}.Fontname=${sub-font}"
                "${style}.PrimaryColour=&H${primaryColour}"
                "${style}.OutlineColour=&H${outlineColour}"
                "${style}.Bold=0"
                "${style}.Italic=-1"
                "${style}.Shadow=0"
                "${style}.Outline=${outlineThickness}"
                "${style}.ScaleX=${fontScale}"
                "${style}.ScaleY=${fontScale}"
              ]))
              ++ (lib.forEach boldStyles (style: [
                "${style}.Borderstyle=4"
                "${style}.BackColour=&H${backColour}"
                "${style}.Fontname=${sub-font}"
                "${style}.PrimaryColour=&H${primaryColour}"
                "${style}.OutlineColour=&H${outlineColour}"
                "${style}.Bold=-1"
                "${style}.Italic=0"
                "${style}.Shadow=0"
                "${style}.Outline=${outlineThickness}"
                "${style}.ScaleX=${fontScale}"
                "${style}.ScaleY=${fontScale}"
              ]))
              ++ (lib.forEach italicBoldStyles (style: [
                "${style}.Borderstyle=4"
                "${style}.BackColour=&H${backColour}"
                "${style}.OutlineColour=&H${outlineColour}"
                "${style}.Fontname=${sub-font}"
                "${style}.PrimaryColour=&H${primaryColour}"
                "${style}.Bold=-1"
                "${style}.Italic=-1"
                "${style}.Shadow=0"
                "${style}.Outline=${outlineThickness}"
                "${style}.ScaleX=${fontScale}"
                "${style}.ScaleY=${fontScale}"
              ]))
              ++ (lib.forEach altStyles (style: [
                # We won't change colors here, just in case
                "${style}.Borderstyle=4"
                "${style}.BackColour=&H${backColour}"
                "${style}.Fontname=${sub-font}"
                "${style}.Bold=0"
                "${style}.Italic=0"
                "${style}.Shadow=0"
                "${style}.Outline=3"
                "${style}.ScaleX=${fontScale}"
                "${style}.ScaleY=${fontScale}"
              ]))
            );
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
            "lookahead=1.0"
            "filter_persistent=yes"
            "af-add=scaletempo2"
          ];
        };
        # Used for things like live streams where they could be large pauses
        "skipsilence-patient" = {
          script-opts-append = [
            "skipsilence-ramp_constant=1.25"
            "skipsilence-ramp_factor=3"
            "skipsilence-ramp_exponent=0.9"
            "skipsilence-speed_max=4"
            "skipsilence-speed_updateinterval=0.05"
            "skipsilence-startdelay=0"
            "skipsilence-threshold_duration=1"
            "lookahead=1.0"
            "filter_persistent=yes"
            "af-add=scaletempo2"
          ];
        };
        "auto-skipsilence-videosync" = {
          profile-cond = ''get("user-data/skipsilence/enabled")'';
          profile-restore = "copy-equal";
          video-sync = "audio";
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
