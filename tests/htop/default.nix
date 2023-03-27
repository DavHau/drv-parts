{
  nixpkgs ? import <nixpkgs> {},
  drv-parts ? import ../../default.nix,
  ...
}: let

  l = nixpkgs.lib // builtins;

  my-htop = drv-parts.lib.derivationFromModules {inherit nixpkgs;} [
    ../../examples/flake-parts/htop/htop.nix
    {
      deps = {nixpkgs, ...}: {inherit (nixpkgs) stdenv;};
      mkDerivation = {
        src = l.mkForce nixpkgs.htop.src;
        version =  l.mkForce nixpkgs.htop.version;
      };
    }
  ];

  nixpkgs-htop = nixpkgs.htop;
in
  assert my-htop.drvPath == nixpkgs-htop.drvPath;
  {
    inherit
      my-htop
      nixpkgs-htop
      ;
    docs = my-htop.docs;
  }
