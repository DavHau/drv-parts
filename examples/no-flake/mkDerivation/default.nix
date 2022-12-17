{
  pkgs ? import <nixpkgs> {},
  drv-parts ? import ../../../default.nix,
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
  };
  makePackage = module: let
    drv = pkgs.lib.evalModules {
      specialArgs = {inherit (pkgs) stdenv; nixpkgsConfig = pkgs.config;};
      modules = [module];
    };
  in
    drv.config.final.derivation;
in
  makePackage hello
