{
  config,
  lib,
  ...
}: let
  l = lib // builtins;
  t = l.types;
in {
  config.final.derivation =
    config.stdenv.mkDerivation config.final.derivation-args;
}
