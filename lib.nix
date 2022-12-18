{
  lib ? import <nixpkgs/lib>,
  drv-backends,
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
    inherit lib;
    mkDerivationBackend = drv-backends.mkDerivation;
  };
in
  {
    inherit
      derivationFromModules
      makeModule
      ;
  }
