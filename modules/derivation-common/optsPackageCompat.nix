# The proposal in https://github.com/NixOS/nix/issues/6507 is not entirely
#   compatible to the current implementation of nix.
# This module adds fields that are needed to ensure compatibility.

{lib, ...}: let
  l = lib // builtins;
  t = l.types;

in {
  drvPath = l.mkOption {
    type = t.path;
  };
  outPath = l.mkOption {
    type = t.path;
  };
  type = l.mkOption {
    type = t.str;
  };
}
