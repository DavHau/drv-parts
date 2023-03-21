{
  nixpkgs ? import <nixpkgs> {},
  drv-parts ? import ../../default.nix {inherit (nixpkgs) lib;},
  ...
}: let

  l = nixpkgs.lib // builtins;

  commonModule = {
    imports = [
      drv-parts.modules.drv-parts.mkDerivation
    ];
    name = "test";
    version = "1.2.3";
    deps = {nixpkgs, ...}: {
      stdenv = nixpkgs.stdenv;
    };
    mkDerivation.phases = ["buildPhase"];
  };

  src-as-module = drv-parts.lib.derivationFromModules {inherit nixpkgs;}
    {
      imports = [commonModule];
      mkDerivation = {
        src = {
          imports = [commonModule];
          mkDerivation.buildPhase = ''
            echo "my-source" > $out
          '';
        };
        buildPhase = "cp $src $out";
      };
    };

in
  {
    inherit
      src-as-module
      ;
  }
