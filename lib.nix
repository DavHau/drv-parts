{
  lib ? import <nixpkgs/lib>,
  drv-parts ? import ./. {inherit lib;},
}:
let
  l = lib // builtins;

  derivationFromModules = dependencySets: modules: let
    drv = lib.evalModules {
      modules =
        (l.toList modules)
        ++ [
          ./modules/drv-parts/package
          ./modules/drv-parts/flags
        ];
      specialArgs = {
        inherit dependencySets drv-parts;
      };
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
