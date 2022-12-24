{
  config,
  lib,
  ...
}: let
  l = lib // builtins;
  t = l.types;

in {
  imports = [
    ../derivation-common/implementation.nix
  ];
  config.final.derivation = derivation config.final.derivation-args;
}
