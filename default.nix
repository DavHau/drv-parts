{
  lib ? import <nixpkgs/lib>,
}:
let
  l = lib // builtins;
  modules.drv-parts = {
    # import one of these to pick the backend for your derivation
    # TODO: add more backends like for ex.: buildPythonPackage, etc.
    builtins-derivation = ./modules/drv-parts/builtins-derivation;
    mkDerivation = ./modules/drv-parts/mkDerivation;

    # the base derivation type used by the drv-parts module
    derivation-common = ./modules/drv-parts/derivation-common;
  };

  modules.flake-parts = {
    # the main module creatig the `.pkgs.[...]` option for flake-parts
    drv-parts = ./modules/drv-parts/drv-parts.nix;
  };

  drv-parts = {
    inherit
      modules
      ;
    lib = import ./lib.nix {inherit drv-parts lib;};
  };
in
  drv-parts
