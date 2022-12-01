{config, lib, ...}: let
  l = lib // builtins;
  t = l.types;
in {
  options.type = l.mkOption {
    type = t.enum ["derivation"];
    default = "derivation";
  };
  config = {
    inherit (config.derivation) drvPath;
  };
}
