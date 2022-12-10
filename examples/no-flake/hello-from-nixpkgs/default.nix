{
  pkgs ? import <nixpkgs> {},
  drv-parts ? import ../../../default.nix,
  ...
}: let
  helloModule = import ../../../lib/makeModule.nix {
    inherit (pkgs) lib;
    mkDerivationBackend = drv-parts.modules.mkDerivation;
  }
    "${/home/grmpf/synced/projects/github/nixpkgs/pkgs/applications/misc/hello}/default.nix";
  hello = {
    # select mkDerivation as a backend for this package
    imports = [
      drv-parts.modules.mkDerivation
      helloModule
    ];

    deps = {
      hello = finalHello;
      inherit (pkgs)
        fetchurl
        stdenv
        callPackage
        nixos
        testers
        ;
    };

    # set options
    name = "hello";
  };
  makePackage = module: pkgs.lib.evalModules {
    specialArgs = {inherit (pkgs) stdenv; nixpkgsConfig = pkgs.config;};
    modules = [module];
  };

  finalHello = makePackage hello;
in
  finalHello
