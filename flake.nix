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
        lib = {
          # function that converts a legacy default.nix to a drv-parts module.
          makeModule = import ./lib/makeModule.nix {
            inherit (nixpkgs) lib;
            mkDerivationBackend = self.modules.mkDerivation;
          };
        };
        modules = (import ./default.nix).modules;
      };

      perSystem = {system, pkgs, ...}: {
        packages.tests-examples = pkgs.writeShellScriptBin "tests-examples" ''
          set -eu -o pipefail
          for example in $(find ./examples/flake-parts/ -type f); do
            echo "testing example $example"
            nix flake check "$example" -L \
              --show-trace \
              --no-write-lock-file \
              --override-input drv-parts ${self}
          done
          for example in $(find ./examples/no-flake/ -type f); do
            echo "testing example $example"
            nix build -f "$example" -L \
              --show-trace \
              --no-link
          done
        '';
      };
    };
}
