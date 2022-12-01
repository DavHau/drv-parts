let
  modules = {
    # import one of these to pick the backend for your derivation
    # TODO: add more backends like for ex.: buildPythonPackage, etc.
    derivation = ./modules/derivation;
    mkDerivation = ./modules/mkDerivation;

    # the main module creatig the `.pkgs.[...]` option for flake-parts
    drv-parts = ./modules/drv-parts.nix;

    # the base derivation type used by the drv-parts module
    derivation-common = ./modules/derivation-common;
  };
in
  {
    inherit modules;
  }
