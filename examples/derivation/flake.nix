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
  }:
    flake-parts.lib.mkFlake {inherit self;} {
      systems = ["x86_64-linux"];

      # enable the drv-parts plugin for flake-parts
      imports = [drv-parts.modules.drv-parts];

      perSystem = {config, pkgs, system, ...}: {
        checks = config.packages;
        pkgs.hello = {

          # select mkDerivation as a backend for this package
          imports = [drv-parts.modules.derivation];

          # # set options
          name = "test";
          builder = "/bin/sh";
          args = ["-c" "echo $name > $out"];
          system = system;
        };
      };
    };
}
