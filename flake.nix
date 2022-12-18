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
  }: let
    defaultNix = import ./default.nix {inherit (nixpkgs) lib;};
  in
    flake-parts.lib.mkFlake {inherit self;} {
      systems = ["x86_64-linux"];

      flake = {
        inherit (defaultNix)
          drv-backends
          lib
          modules
          ;
        flakeModule = self.modules.drv-parts;
      };

      perSystem = {system, pkgs, ...}: {
        packages.tests-examples = pkgs.writeShellScriptBin "tests-examples" ''
          set -eu -o pipefail
          for example in $(find ./examples/flake-parts/ -type f); do
            echo "building example $example"
            nix flake check "$example" -L \
              --show-trace \
              --no-write-lock-file \
              --override-input drv-parts ${self}
          done
          for example in $(find ./examples/no-flake/ -type f); do
            echo "building example $example"
            nix build -f "$example" -L \
              --show-trace \
              --no-link
          done
          for example in $(find ./tests/ -type f); do
            echo "building test $example"
            nix build -f "$example" -L \
              --show-trace \
              --no-link
          done
        '';
      };
    };
}
