{
  lib ? import <nixpkgs/lib>
}:
let
  l = lib // builtins;

  derivationFromModules = modules: let
    drv = lib.evalModules {
      modules = if l.isList modules then modules else [modules];
    };
  in
    drv.config.final.derivation;

  makeModule = import ./lib/makeModule.nix {
    inherit lib drvPartsLib;
  };

  drvPartsLib = {
    inherit
      derivationFromModules
      makeModule
      ;
  };
in
  drvPartsLib
