{
  nixpkgs ? import <nixpkgs> {},
  drv-parts ? import ../../../default.nix,
  ...
}: let
  hello = {config, ...}: {
    # select mkDerivation as a backend for this package
    imports = [drv-parts.modules.drv-parts.mkDerivation];

    deps = {nixpkgs, ...}: {inherit (nixpkgs) stdenv;};

    flagsOffered = {
      enableFoo = "build with foo";
    };

    name =
        if config.flags.enableFoo
        then "hello-with-foo"
        else "hello";

    version = nixpkgs.hello.version;

    mkDerivation = {
      src = nixpkgs.hello.src;
      doCheck = true;
    };
  };
in
  drv-parts.lib.derivationFromModules {inherit nixpkgs;} hello
