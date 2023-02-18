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
    ../pkg-func
  ];

  config.final.package-func = lib.mkDefault builtins.derivation;

  config.final.package.name = config.name;
}
