{ self, lib, ... }: {
  flake.lib = let
    l = lib // builtins;

    derivationFromModules = packageSets: modules: let
      drv = lib.evalModules {
        modules =
          (l.toList modules)
          ++ [
            ../drv-parts/core
          ];
        specialArgs = {
          inherit packageSets;
          drv-parts.modules = self.modules;
        };
      };
    in
      drv.config.public;

    makeModule = import ../../lib/makeModule.nix {
      inherit lib;
    };

    mkDerivation-based = import ../../lib/mkDerivation-based.nix;

    drvPartsLib = {
      inherit
        derivationFromModules
        makeModule
        mkDerivation-based
        ;
    };
  in
    drvPartsLib;
}
