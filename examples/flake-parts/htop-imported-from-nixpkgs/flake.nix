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
      imports = [drv-parts.flakeModule];

      perSystem = {config, pkgs, ...}: {

        imports = let
          modulesMadeFromNixpkgs = import ./drvs.nix {
            inherit (drv-parts.lib) makeModule;
            inherit (config) packages;
            inherit nixpkgs pkgs;
          };
        in
          [modulesMadeFromNixpkgs];

        # now, that we have converted nixpkgs package functions to modules,
        # we can use the module system to configure the packages
        drvs = {
          # these options have been generated automatically by `makeModule`
          htop.systemdSupport = true;
          htop.sensorsSupport = true;
          htop.buildInputs = [
            # add build inputs here
          ];
          htop.patches = [
            # add patches here
          ];

          # `sensord` and `rrdtool` are bool flags, but because of their names,
          #   makeModule detected them as dependencies.
          lm_sensors.deps.sensord = false;
          lm_sensors.deps.rrdtool = null;

          ncurses.deps.abiVersion = "6";
          ncurses.mouseSupport = false;
          ncurses.unicodeSupport = true;
          ncurses.withCxx = true;
          ncurses.enableStatic = false;
        };

        checks =
          # assure that converting default.nix packages to modules did
          # not impact the drv hash
          assert config.packages.htop.drvPath == pkgs.htop.drvPath;
          config.packages;
      };
    };
}
