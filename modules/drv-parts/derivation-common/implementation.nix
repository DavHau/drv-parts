{
  config,
  lib,
  options,
  extendModules,
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

  # ensure that none of the env variables collide with the top-level options
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

  outputs = l.unique config.outputs;

  # all args that are passed directly to the final derivation function
  args = finalArgs // envChecked // {inherit outputs;};

in {

  # the final package function args
  config.final.package-args = args;
}
