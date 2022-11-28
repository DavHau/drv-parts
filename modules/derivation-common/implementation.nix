{config, lib, pkgs, ...}: let
  l = lib // builtins;
  t = l.types;
in {
  config = {inherit (config.derivation) drvPath;};
}
