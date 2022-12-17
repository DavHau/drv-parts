{
  pkgs ? import <nixpkgs> {},
  drv-parts ? import ../../default.nix {inherit (pkgs) lib;},
  ...
}: let

  l = pkgs.lib // builtins;

  makePackage = modules: let
    drv = pkgs.lib.evalModules {
      specialArgs = {
        inherit (pkgs) stdenv;
        inherit (drv-parts) drv-backends;
        dependencySets = {inherit pkgs;};
        nixpkgsConfig = pkgs.config;
      };
      modules = modules;
    };
  in
    drv.config.final.derivation;

  my-htop = makePackage [
    ../../examples/flake-parts/htop/htop.nix
    {
      src = l.mkForce pkgs.htop.src;
      version =  l.mkForce pkgs.htop.version;
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
