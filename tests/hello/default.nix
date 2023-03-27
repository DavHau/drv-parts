{
  pkgs ? import <nixpkgs> {},
  drv-parts ? import ../../default.nix,
  ...
}: let

  my-hello = import ../../examples/no-flake/mkDerivation/default.nix {
    inherit pkgs drv-parts;
  };
  nixpkgs-hello = pkgs.hello;
in
  assert my-hello.drvPath == nixpkgs-hello.drvPath;
  {
    inherit
      my-hello
      nixpkgs-hello
      ;
  }
