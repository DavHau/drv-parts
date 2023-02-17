{
  config,
  lib,
  options,
  ...
}: let
  l = lib // builtins;
  t = l.types;

  passAsFile =
    if config.passAsFile == null
    then {}
    else l.genAttrs config.passAsFile (var: true);

  keepArg = key: val:
    (config.argsForward.${key} or false || passAsFile ? ${key})
    && (val != null);

  finalArgs = l.filterAttrs keepArg config;

  # esure that none of the env variables collides with the top-level options
  envChecked =
    l.mapAttrs
    (key: val:
      if config.argsForward.${key} or false
      then throw (envCollisionError key)
      else val)
    config.env;

  drvDebugName =
    if config ? name && config.name != null
    then config.name
    else config.pname;

  # generates error message for env variable collision
  envCollisionError = key: ''
    Error while evaluating definitions for derivation ${drvDebugName}
    The environment variable defined via `env.${key}' collides with the top-level option `${key}'.
    Specify the top-level option instead, or rename the environment variable.
  '';

  # all args that are massed directly to mkDerivation
  args =
    finalArgs
    // envChecked
    ;

in {

  # the final derivation args
  config.final.derivation-args = args;

  # the final derivation
  config.final.derivation =
    config.final.derivation-func config.final.derivation-args;
}
