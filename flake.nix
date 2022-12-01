{
  description = ''
    construct derivations using the nixos-module system
  '';

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    flake-parts,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit self;} {
      systems = ["x86_64-linux"];

      flake = {
        flakeModule = self.modules.drv-parts;
        drv-backends = {
          inherit (self.modules)
            derivation
            mkDerivation
            ;
        };
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
      };

      perSystem = {system, pkgs, ...}: {
        packages.tests-examples = pkgs.writeShellScriptBin "tests-examples" ''
          set -eu -o pipefail
          for example in $(find ./examples); do
            echo "testing example $example"
            nix flake check "$example" -L \
              --show-trace \
              --no-write-lock-file \
              --override-input drv-parts ${self}
          done
        '';
      };
    };
}
