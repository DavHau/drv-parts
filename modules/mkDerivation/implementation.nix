{
  config,
  nixpkgsConfig,
  lib,
  pkgs,
  ...
}: let
  l = lib // builtins;
  t = l.types;
  stdenv = pkgs.stdenv;
  argsFiltered = l.removeAttrs config [
    # attrs introduced by module system
    "_module"
    # this module's custom options
    "derivation"
    "env"
    "drvPath"
    # attributes that should not be passed if null
    "args"
    "outputHash"
    "realBuilder"
    "pname"
    "version"
    "__contentAddressed"
    "builder"
    "src"
    "srcs"
    "sourceRoot"
    "phases"
    "unpackCmd"
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

  omitIfNull = argName:
    if config.${argName} == null
    then {}
    else {${argName} = config.${argName};};

  args =
    envChecked
    // argsFiltered
    // (omitIfNull "args")
    // (omitIfNull "outputHash")
    // (omitIfNull "realBuilder")
    // (omitIfNull "pname")
    // (omitIfNull "version")
    // (omitIfNull "__contentAddressed")
    // (omitIfNull "builder")
    // (omitIfNull "src")
    // (omitIfNull "srcs")
    // (omitIfNull "sourceRoot")
    // (omitIfNull "phases")
    // (omitIfNull "unpackCmd")
    ;
in {
  config.derivation =
    stdenv.mkDerivation args;
}
