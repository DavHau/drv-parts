{
  pkgs ? import <nixpkgs> {},
  drv-parts ? import ../../../default.nix {inherit (pkgs) lib;},
  ...
}: let
  hello = {
    # select mkDerivation as a backend for this package
    imports = [drv-parts.modules.mkDerivation];

    # set options
    pname = "hello";
    version = pkgs.hello.version;
    src = pkgs.hello.src;
    doCheck = true;
    stdenv = pkgs.stdenv;
  };
in
  drv-parts.lib.derivationFromModules hello
