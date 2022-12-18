{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    drv-parts.url = "nixpkgs";
  };

  outputs = {
    self,
    flake-parts,
    drv-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      # enable the drv-parts plugin for flake-parts
      imports = [drv-parts.flakeModule];

      perSystem = {config, lib, pkgs, extendModules, ...}: {
        checks = config.packages;

        drvs = {

          # htop defined via submodule
          htop.imports = [./htop.nix];

          htop.stdenv = pkgs.stdenv;

          # overriding htop
          htop-mod = {
            imports = [./htop.nix];
            pname = lib.mkForce "htop-mod";
            sensorsSupport = false;
            stdenv = pkgs.stdenv;
          };
        };

        packages = {

          # overriding htop without drv-parts
          htop-mod-nixpkgs = let
            htop-attrs-overridden = pkgs.htop.overrideAttrs (old: {
              pname = "htop-mod";
            });
          in
            htop-attrs-overridden.override (old: {
              sensorsSupport = true;
            });
        };
      };
    };
}
