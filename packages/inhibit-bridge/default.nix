{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule {
  pname = "inhibit-bridge";
  version = "latest";

  src = fetchFromGitHub {
    owner = "bdwalton";
    repo = "inhibit-bridge";
    rev = "962b6583f82662efd1a52a4ee14baf545eda7c32";
    hash = "sha256-UEJtQ7z9O+14a/5vEGjMWnFOcrTapLgWYcPBmSGJmnk=";
  };

  vendorHash = "sha256-DGxvhBmEdPqfupBLQSotkwhGvUDYBsAH5d+27DAOhQY=";

  meta = {
    description = "Sends DBUS inhibit requests to logind inhibit";
    homepage = "https://github.com/bdwalton/inhibit-bridge";
    license = lib.licenses.bsd2;
  };

}
