{
  pkgs ? import <nixpkgs> {},
  drv-parts ? import ../../../default.nix {inherit (pkgs) lib;},
  ...
}: let
  hello = {config, ...}: {
    # select mkDerivation as a backend for this package
    imports = [drv-parts.modules.drv-parts.mkDerivation];

    # set options
    pname =
      if config.flags.enableFoo
      then "hello-with-foo"
      else "hello";
    version = pkgs.hello.version;
    src = pkgs.hello.src;
    doCheck = true;
    stdenv = pkgs.stdenv;

    flagsOffered = {
      enableFoo = "build with foo";
    };
  };
in
  drv-parts.lib.derivationFromModules {} hello
