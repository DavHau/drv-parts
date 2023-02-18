{
  lib ? import <nixpkgs/lib>
}:
let
  l = lib // builtins;

  derivationFromModules = dependencySets: modules: let
    drv = lib.evalModules {
      modules = if l.isList modules then modules else [modules];
      specialArgs = {inherit dependencySets;};
    };
  in
    drv.config.final.package;

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
