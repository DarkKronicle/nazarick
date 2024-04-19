# Nazarick, my NixOS Config

> The world is all yours

Named after the Great Tomb of Nazarick from Overlord (very good show).

## Structure

This configuration uses [snowfall](https://snowfall.org/) to handle modules and various components.

I've tried to keep this configuration fairly simple, but currently I haven't done a great job
at properly modularizing various configuration sections. This will hopefully improve soon!

Nix has infected my brain and I've gone a bit insane at declaratively specifying configurations.
Most notably:
- Plasma configuration - panels, wallpapers, lockscreen, etc.
- mpv - plugins, keybinds, shaders, etc.

For some of the more complicated modules I've written a small blog post over at my [garden](https://garden.darkkronicle.com/),
so maybe give that a check. It also has my basic install instructions.

## Credits and Inspiration

I have looked at a *ton* of Nix configs for inspiration and implementations. Here they are (in no particular order):
- [Jake Hamilton](https://github.com/jakehamilton/config) - Original snowfall repo I based mine off. Creator of snowfall.
- [khaneliman](https://github.com/khaneliman/khanelinix) - The second snowfall repo I found. Cool stuff.
- [LuisChDev](https://github.com/nix-community/nur-combined/blob/2c0f9f6f2b853efec50eb90218748c3da55e8df0/repos/LuisChDev/pkgs/nordvpn/default.nix#L88) - Original NordVPN package. Outdated at time of writing.
- [erosanix](https://github.com/emmanuelrosa/erosanix/blob/622114db93eacaff38c4b999b6f674c4134d1277/pkgs/mkwindowsapp/default.nix) - Packaging wine apps within Nix.
- [sioodmy](https://github.com/sioodmy/dotfiles)
- [EmergentMind](https://github.com/EmergentMind/nix-config) - Good YouTube videos. Based my sops on theirs.
- [IogaMaster](https://github.com/IogaMaster/dotfiles)
