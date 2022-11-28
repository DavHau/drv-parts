{config, lib, pkgs, ...}: let
  l = lib // builtins;
  t = l.types;
  argsFiltered = l.removeAttrs config [
    # attrs introduced by module system
    "_module"
    # this module's custom options
    "derivation"
    "env"
    # attributes that should not be passed if null
    "args"
    "outputHash"
    "drvPath"
  ];
  # esure that none of the env variables collides with the top-level options
  envCollisionError = key: ''
    The environment variable declared via env.${key} collides with option ${key}.
    Specify the option instead, or rename the environment variable.
  '';
  envChecked =
    l.mapAttrs
    (key: val:
      if config ? ${key}
      then throw (envCollisionError key)
      else val)
    config.env;
  args =
    envChecked
    // argsFiltered
    // (
      if config.args == null
      then {}
      else {inherit (config) args;}
    )
    // (
      if config.outputHash == null
      then {}
      else {inherit (config) outputHash;}
    );
in {
  config.derivation = derivation args;
}
