{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    drv-parts.url = "github:DavHau/drv-parts";
    drv-parts.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    flake-parts,
    drv-parts,
    nixpkgs,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      # enable the drv-parts plugin for flake-parts
      imports = [drv-parts.modules.flake-parts.drv-parts];

      perSystem = {config, pkgs, lib, ...}: {

        imports = let
          modulesMadeFromNixpkgs = import ./drvs.nix {
            inherit (drv-parts.lib) makeModule;
            inherit (config) packages;
            inherit nixpkgs pkgs;
          };
        in
          [modulesMadeFromNixpkgs];

        # Because nixpkgs package functions were conmverted to modules,
        # configuration/overriding can be done like this:
        drvs = {
          # these options have been generated automatically by `makeModule`
          htop.flags = {
            systemdSupport = true;
            sensorsSupport = true;
          };
          htop.mkDerivation = {
            buildInputs = [
              # add build inputs here
            ];
            patches = [
              # add patches here
            ];
          };

          # `sensord` and `rrdtool` are bool flags, but because of their names,
          #   makeModule detected them as dependencies.
          lm_sensors.deps.sensord = false;
          lm_sensors.deps.rrdtool = null;

          ncurses.deps.abiVersion = "6";
          ncurses.flags = {
            mouseSupport = false;
            unicodeSupport = true;
            withCxx = true;
            enableStatic = false;
          };
        };

        checks =
          # assure that converting default.nix packages to modules did
          # not impact the drv hash
          assert config.packages.htop.drvPath == config.packages.htop-nixpkgs.drvPath;
          config.packages;

        packages.htop-nixpkgs = pkgs.htop;
      };
    };
}
