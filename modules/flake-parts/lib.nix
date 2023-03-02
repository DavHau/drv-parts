{ self, lib, ... }: {
  flake.lib = let
    l = lib // builtins;

    derivationFromModules = dependencySets: modules: let
      drv = lib.evalModules {
        modules =
          (l.toList modules)
          ++ [
            ../drv-parts/core
          ];
        specialArgs = {
          inherit dependencySets;
          drv-parts.modules = self.modules;
        };
      };
    in
      drv.config.public;

    makeModule = import ../../lib/makeModule.nix {
      inherit lib;
    };

    drvPartsLib = {
      inherit
        derivationFromModules
        makeModule
        ;
    };
  in
    drvPartsLib;
}
