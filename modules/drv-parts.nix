{ config, lib, flake-parts-lib, ... }:
let
  l = lib // builtins;
  t = l.types;
in {
  options.perSystem =
    flake-parts-lib.mkPerSystemOption ({pkgs, ...}: {
      options.pkgs = l.mkOption {
        type = t.lazyAttrsOf (
          t.submoduleWith {
            modules = [./mkDerivation];
            specialArgs = {
              inherit pkgs;
              nixpkgsConfig = pkgs.config;
            };
          }
        );
      };
    });

  config.perSystem = {config, pkgs, ...}: {
    config.packages = l.mapAttrs (name: pkg: pkg.derivation) config.pkgs;
  };

}
