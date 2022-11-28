{config, lib, ...}: let
  l = lib // builtins;
  t = l.types;
in {
  imports = [
    ../derivation-commmon
  ];
  options = {
    # basic arguments
    builder = lib.mkOption {
      type = t.oneOf [t.str t.path t.package];
    };
    __contentAddressed = lib.mkOption {
      type = t.bool;
      default = false;
    };
  };
}
