{
  pkgs ? import <nixpkgs> {},
  drv-parts ? import ../../default.nix {inherit (pkgs) lib;},
  ...
}: let

  l = pkgs.lib // builtins;

  makePackage = modules: let
    drv = pkgs.lib.evalModules {
      specialArgs = {
        inherit (drv-parts) drv-backends;
      };
      modules = modules;
    };
  in
    drv.config.final.derivation;

  my-htop = makePackage [
    ../../examples/flake-parts/htop/htop.nix
    {
      stdenv = pkgs.stdenv;
      src = l.mkForce pkgs.htop.src;
      version =  l.mkForce pkgs.htop.version;
      depsFrom = pkgs;
    }
  ];

  nixpkgs-htop = pkgs.htop;
in
  assert my-htop.drvPath == nixpkgs-htop.drvPath;
  {
    inherit
      my-htop
      nixpkgs-htop
      ;
  }
