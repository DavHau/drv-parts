{
  pkgs ? import <nixpkgs> {},
  drv-parts ? import ./default.nix {inherit (pkgs) lib;},
}: let
  l = pkgs.lib // builtins;

  evalModules = modules: l.evalModules {inherit modules;};

  getOptions = modules: (evalModules modules).options;

  getDocs = module: pkgs.nixosOptionsDoc {
    options = getOptions [module];
  };

  docs = l.mapAttrs (_: getDocs) drv-parts.modules.drv-parts;
in
  docs
