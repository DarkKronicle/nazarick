{ mylib, ... }:
{
  imports = mylib.scanPaths ./.;
  systemd.user.startServices = "sd-switch";
}
