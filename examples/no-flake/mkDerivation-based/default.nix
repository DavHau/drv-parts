{
  nixpkgs ? import <nixpkgs> {},
  drv-parts ? import ../../../default.nix {inherit (nixpkgs) lib;},
  ...
}: let
  hello = {config, ...}: {

    # integrate custom build function based on mkDerivation
    imports = [
      (drv-parts.lib.mkDerivation-based "myBuildFunc")
    ];

    deps = {nixpkgs, ...}: {
      inherit (nixpkgs) stdenv;
      myBuildFunc = nixpkgs.stdenv.mkDerivation;
    };

    name = "test-mkDerivation-based";
    version = nixpkgs.hello.version;

    mkDerivation = {
      phases = ["buildPhase"];
      buildPhase = "touch $out";
    };

    myBuildFunc = {
      customArgExample = "foo";
    };
  };
in
  drv-parts.lib.derivationFromModules {inherit nixpkgs;} hello
