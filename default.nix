{
  lib ? import <nixpkgs/lib>,
}:
let
  l = lib // builtins;
  modules.drv-parts = {
    # import one of these to pick the backend for your derivation
    # TODO: add more backends like for ex.: buildPythonPackage, etc.
    derivation = ./modules/derivation;
    mkDerivation = ./modules/mkDerivation;

    # the base derivation type used by the drv-parts module
    derivation-common = ./modules/derivation-common;
  };

  modules.flake-parts = {
    # the main module creatig the `.pkgs.[...]` option for flake-parts
    drv-parts = ./modules/drv-parts.nix;
  };
in
  {
    inherit
      modules
      ;
    lib = import ./lib.nix {inherit lib;};
  }
