# The proposal in https://github.com/NixOS/nix/issues/6507 is not entirely
#   compatible to the current implementation of nix.
# This module adds fields that are needed to ensure compatibility.

{config, lib, outputs, ...}: let
  l = lib // builtins;
  t = l.types;

in {

  options = {
    drvPath = l.mkOption {
      type = t.path;
    };
    outPath = l.mkOption {
      type = t.path;
    };
    type = l.mkOption {
      type = t.str;
    };
  };

  config = {
    type = "derivation";
  };
}
