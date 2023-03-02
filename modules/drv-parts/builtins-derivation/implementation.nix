{
  config,
  lib,
  ...
}: let
  l = lib // builtins;
  t = l.types;

  cfg = config.builtins-derivation;

  outputs = l.unique cfg.outputs;

  keepArg = key: val: val != null;

  finalArgs = l.filterAttrs keepArg cfg;

  # ensure that none of the env variables collide with the top-level options
  envChecked =
    l.mapAttrs
    (key: val:
      if config.builtins-derivation.${key} or false
      then throw (envCollisionError key)
      else val)
    config.env;

  # generates error message for env variable collision
  envCollisionError = key: ''
    Error while evaluating definitions for derivation ${config.public.name}
    The environment variable defined via `env.${key}' collides with the top-level option `${key}'.
    Specify the top-level option instead, or rename the environment variable.
  '';

in {
  imports = [
    ../pkg-func/implementation.nix
  ];

  config.final.outputs = cfg.outputs;

  config.final.package-func = lib.mkDefault builtins.derivation;

  config.public.name = cfg.name;

  config.final.package-args = envChecked // finalArgs  // {inherit outputs;};
}
