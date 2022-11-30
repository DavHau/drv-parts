{config, lib, ...}: let
  l = lib // builtins;
  t = l.types;
in {
  imports = [
    ../derivation-common
  ];
  options = {
    # basic arguments
    builder = lib.mkOption {
      type = t.oneOf [t.str t.path t.package];
    };
    name = lib.mkOption {
      type = t.str;
    };
    __contentAddressed = lib.mkOption {
      type = t.bool;
      default = false;
    };
  };
}
