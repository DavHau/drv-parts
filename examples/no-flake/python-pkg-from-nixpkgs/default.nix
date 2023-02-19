{
  nixpkgs ? import <nixpkgs> {},
  drv-parts ? import ../../../default.nix {inherit (nixpkgs) lib;},
  ...
}: let
  l = nixpkgs.lib // builtins;

  # use makeModule to make a module out of applications/misc/hello/default.nix
  pythonModule = drv-parts.lib.makeModule {
    packageFunc =
      nixpkgs.path + /pkgs/development/python-modules/requests/default.nix;
  };

  # define another module to set `deps`
  myModule = {

    deps = {nixpkgs, ...}: {config = nixpkgs // nixpkgs.python3.pkgs;};
  };

  pkg = l.evalModules {
    modules= [
      pythonModule
      myModule
    ];
    specialArgs.dependencySets.nixpkgs = nixpkgs;
  };
in
  pkg.config.final.package
