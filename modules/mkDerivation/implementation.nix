{
  config,
  lib,
  stdenv,
  ...
}: let
  l = lib // builtins;
  t = l.types;
in {
  config.final.derivation =
    stdenv.mkDerivation config.final.derivation-args;
}
