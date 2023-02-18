{
  nixpkgs ? import <nixpkgs> {},
  drv-parts ? import ../../. {inherit (nixpkgs) lib;},
  ...
}: let

l = nixpkgs.lib // builtins;

  # use makeModule to make a module out of applications/misc/hello/default.nix
  helloDefaultNix = drv-parts.lib.makeModule
    (nixpkgs.path + /pkgs/applications/misc/hello/default.nix);

  helloEvaled = l.evalModules {
    modules = [
      helloDefaultNix
      {stdenv = nixpkgs.stdenv;}
    ];
    specialArgs.dependencySets = {};
  };
in
  l.seq helloEvaled.options
  nixpkgs.hello
