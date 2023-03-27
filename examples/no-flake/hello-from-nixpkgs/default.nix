{
  nixpkgs ? import <nixpkgs> {},
  drv-parts ? import ../../../default.nix,
  ...
}: let

  # use makeModule to make a module out of applications/misc/hello/default.nix
  helloDefaultNix = drv-parts.lib.makeModule {
    packageFunc =
      nixpkgs.path + /pkgs/applications/misc/hello/default.nix;
  };

  # define another module to set `deps`
  helloDeps = {

    deps = {nixpkgs, ...}: {
      inherit hello; # the default.nix of hello wants hello as an input.
      inherit (nixpkgs)
        fetchurl
        stdenv
        callPackage
        nixos
        testers
        ;
    };
  };

  hello = drv-parts.lib.derivationFromModules {inherit nixpkgs;} [
    helloDefaultNix
    helloDeps
  ];
in
  hello
