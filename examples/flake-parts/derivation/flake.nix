{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    drv-parts.url = "github:DavHau/drv-parts";
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
      imports = [drv-parts.modules.flake-parts.drv-parts];

      perSystem = {config, pkgs, system, ...}: {
        checks = config.packages;
        drvs.test = {

          # select builtins-derivation as a backend for this package
          imports = [drv-parts.modules.drv-parts.builtins-derivation];

          name = "test";

          # set options
          builtins-derivation = {
            args = ["-c" "echo $name > $out"];
            builder = "/bin/sh";
            system = system;
          };
        };
      };
    };
}
