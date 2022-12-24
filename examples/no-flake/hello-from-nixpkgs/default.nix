{
  pkgs ? import <nixpkgs> {},
  drv-parts ? import ../../../default.nix {inherit (pkgs) lib;},
  ...
}: let

  # use makeModule to make a module out of applications/misc/hello/default.nix
  helloDefaultNix = drv-parts.lib.makeModule
    (pkgs.path + /pkgs/applications/misc/hello/default.nix);

  # define another module to set `deps`
  helloDeps = {

    depsFrom = pkgs // {inherit hello;};

    stdenv = pkgs.stdenv;
  };

  hello = drv-parts.lib.derivationFromModules [
    helloDefaultNix
    helloDeps
  ];
in
  hello
