{
  lib ? import <nixpkgs/lib>,
  drv-parts ? import ../../../default.nix,
  ...
}: let
  hello = {
    # select builtins.derivation as a backend for this package
    imports = [drv-parts.modules.derivation];

    # set options
    name = "test";
    builder = "/bin/sh";
    args = ["-c" "echo $name > $out"];
    system = builtins.currentSystem;
  };
  makePackage = module: let
    drv = lib.evalModules {
      modules = [module];
    };
  in
    drv.config.final.derivation;
in
  makePackage hello
