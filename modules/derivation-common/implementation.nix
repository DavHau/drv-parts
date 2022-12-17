{
  config,
  lib,
  ...
}: let
  l = lib // builtins;
  t = l.types;

  keepArg = key: val:
    (config.argsForward.${key} or false)
    && (val != null);

  finalArgs = l.filterAttrs keepArg config;

  # esure that none of the env variables collides with the top-level options
  envChecked =
    l.mapAttrs
    (key: val:
      if finalArgs ? ${key}
      then throw (envCollisionError key)
      else val)
    config.env;

  # generates error message for env variable collision
  envCollisionError = key: ''
    The environment variable declared via env.${key} collides with option ${key}.
    Specify the option instead, or rename the environment variable.
  '';

  # all args that are massed directly to mkDerivation
  args =
    envChecked
    // finalArgs
    ;

in {
  config.final.derivation-args = args;
}
