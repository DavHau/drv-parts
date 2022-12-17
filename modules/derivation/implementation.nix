{
  config,
  lib,
  ...
}: let
  l = lib // builtins;
  t = l.types;

in {
  config.final.derivation = derivation config.final.derivation-args;
}
