{
  lib,
  pkgs,
  config,
  ...
}:
let

  cfg = config.nazarick.gui.waybar;

  dftGroup = lr: {
    orientation = "inherit";
    drawer = {
      transition-duration = 500;
      transition-left-to-right = lr;
    };
  };

in
{
  options.nazarick.gui.waybar = {
    enable = lib.mkEnableOption "waybar";
  };

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      style = ./style.css;
      # Inspired heavily by:
      # https://github.com/niksingh710/gdots/blob/cf65b513045aff7ddf32a2cf488202cedcff5c06/.config/waybar/style.css
      settings = [
        {
          ipc = true;
          position = "right";
          margin = "5 5 5 0";
          orientation = "inherit";
          modules-left = [
            # "group/info"
            "sway/workspaces"
          ];
          modules-right = [
            "group/brightness"
            "group/sound"
            "tray"
            "group/power"
            "clock"
          ];
          "group/info" = (dftGroup false) // {
            modules = [ "memory" ];
          };
          "group/brightness" = (dftGroup false) // {
            modules = [
              "backlight"
              "backlight/slider"
            ];
          };
          "sway/workspaces" = {
            all-outputs = true;

          };
          "backlight" = {
            device = "intel_backlight";
            format = "{icon}";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
            ];
            on-scroll-down = "swayosd-client --brightness -5";
            on-scroll-up = "swayosd-client --brightness +5";
            tooltip = true;
            tooltip-format = "Brightness: {percent}% ";
            smooth-scrolling-threshold = 1;
          };
          "backlight/slider" = {
            min = 5;
            "max" = 100;
            "orientation" = "vertical";
            "device" = "intel_backlight";
          };
          "group/sound" = {
            orientation = "inherit";
            modules = [ "group/audio" ];
          };
          "group/audio" = (dftGroup false) // {
            modules = [
              "pulseaudio"
              "pulseaudio#mic"
              "pulseaudio/slider"
            ];
          };
          "group/connection" = {
            orientation = "inherit";
            modules = [ "group/bluetooth" ];
          };
          "group/network" = (dftGroup true) // {
            modules = [
              "network"
              "network#speed"
            ];
          };
          "group/bluetooth" = (dftGroup true) // {
            modules = [
              "bluetooth"
              "bluetooth#status"
            ];
          };
          "group/power" = (dftGroup false) // {
            modules = [ "battery" ];
          };
          "tray" = {
            icon-size = 18;
            spacing = 10;
          };
          "pulseaudio" = {
            format = "{icon}";
            format-bluetooth = "{icon}";
            tooltip-format = "{volume}% {icon} | {desc}";
            format-muted = "󰖁";
            format-icons = {
              headphones = "󰋌";
              handsfree = "󰋌";
              headset = "󰋌";
              phone = "";
              portable = "";
              car = " ";
              default = [
                "󰕿"
                "󰖀"
                "󰕾"
              ];
            };
            on-click = "swayosd-client --output-volume mute-toggle";
            # on-click-middle = "pavucontrol";
            on-scroll-up = "swayosd-client --output-volume +5";
            on-scroll-down = "swayosd-client --output-volume -5";
            smooth-scrolling-threshold = 1;
          };
          "pulseaudio#mic" = {
            format = "{format_source}";
            format-source = "";
            format-source-muted = "";
            tooltip-format = "{volume}% {format_source} ";
            on-click = "swayosd-client --input-volume mute-toggle";
            on-scroll-down = "swayosd-client --input-volume -1";
            on-scroll-up = "swayosd-client --input-volume +1";
          };
          "pulseaudio/slider" = {
            min = 0;
            max = 140;
            orientation = "vertical";
          };
          network = {
            format = "{icon}";
            format-icons = {
              wifi = [ "󰤨" ];
              ethernet = [ "󰈀" ];
              disconnected = [ "󰖪" ];
            };
            format-wifi = "󰤨";
            format-ethernet = "󰈀";
            format-disconnected = "󰖪";
            format-linked = "󰈁";
            tooltip = false;
            # on-click = "pgrep -x rofi &>/dev/null && notify-send rofi || networkmanager_dmenu";
          };
          bluetooth = {
            format-on = "";
            format-off = "󰂲";
            format-disabled = "";
            format-connected = "<b></b>";
            tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
            tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
            # on-click = "rofi-bluetooth -config ~/.config/rofi/menu.d/network.rasi -i";
          };
          "bluetooth#status" = {
            format-on = "";
            format-off = "";
            format-disabled = "";
            format-connected = "<b>{num_connections}</b>";
            format-connected-battery = "<small><b>{device_battery_percentage}%</b></small>";
            tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
            tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
            # on-click = "rofi-bluetooth -config ~/.config/rofi/menu.d/network.rasi -i";
          };
          battery = {
            rotate = 270;
            states = {
              good = 95;
              warning = 30;
              critical = 15;
            };
            format = "{icon}";
            format-charging = "<b>{icon} </b>";
            format-full = "<span color='#82A55F'><b>{icon}</b></span>";
            format-icons = [
              "󰁻"
              "󰁼"
              "󰁾"
              "󰂀"
              "󰂂"
              "󰁹"
            ];
            tooltip-format = "{timeTo} {capacity} % | {power} W";
          };
          clock = {
            format = "{:%H\n%M}";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "month";
              mode-mon-col = 3;
              weeks-pos = "right";
              on-scroll = 1;
              on-click-right = "mode";
              format = {
                today = "<span color='#a6e3a1'><b><u>{}</u></b></span>";
              };
            };
          };
        }
      ];
    };

  };
}
