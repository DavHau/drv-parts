{ config, lib, flake-parts-lib, ... }:
let
  l = lib // builtins;
  t = l.types;
in {
  options.perSystem =
    flake-parts-lib.mkPerSystemOption ({pkgs, inputs', ...}: {
      options.pkgs = l.mkOption {
        type = t.lazyAttrsOf (
          t.submoduleWith {
            modules = [./derivation-common];
            specialArgs = {
              inherit pkgs;
              nixpkgsConfig = pkgs.config;
              inherit inputs';
            };
          }
        );
      };
    });

  config.perSystem = {config, pkgs, ...}: {
    /*
      TODO: I'm not sure yet if we should expose just the evaled module instead.
      The evaled module is also a valid derivation because we set
        `type = "derivation"` and `drvPath`, but it is currently missing
        attributes like `overrideAttrs` or `out`, etc.
    */
    # config.packages = config.pkgs;

    /*
      This exposes the `.derivation` attribute (the actual derivation) of each
        defined `pkgs.xxx` under the flake output `packages`.
    */
    config.packages = l.mapAttrs (name: pkg: pkg.derivation) config.pkgs;
  };

}
