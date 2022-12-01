{
  pkgs ? import <nixpkgs> {},
  drv-parts ? import ../../../default.nix,
  ...
}: let
  hello = {
    # select mkDerivation as a backend for this package
    imports = [drv-parts.modules.mkDerivation];

    # set options
    name = "hello";
    src = pkgs.fetchurl {
      url = "mirror://gnu/hello/hello-2.12.1.tar.gz";
      sha256 = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
    };
  };
  makePackage = module: pkgs.lib.evalModules {
    specialArgs = {inherit (pkgs) stdenv; nixpkgsConfig = pkgs.config;};
    modules = [module];
  };
in
  makePackage hello
