{
  nixpkgs ? import <nixpkgs> {},
  drv-parts ? import ../../.,
  ...
}: let

l = nixpkgs.lib // builtins;

  # use makeModule to make a module out of applications/misc/hello/default.nix
  helloDefaultNix = drv-parts.lib.makeModule {
    packageFunc = (nixpkgs.path + /pkgs/applications/misc/hello/default.nix);
  };

  helloEvaled = l.evalModules {
    modules = [
      helloDefaultNix
      {deps = {nixpkgs, ...}: {inherit (nixpkgs) stdenv;};}
    ];
    specialArgs.dependencySets = {};
  };
in
  l.seq helloEvaled.options
  nixpkgs.hello
