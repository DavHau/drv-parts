{
  config,
  lib,
  ...
}: let
  l = lib // builtins;
  t = l.types;

  # args that should not be passed to mkDerivation
  argsIgnore = [
    # attrs introduced by module system
    "_module"
    # this module's options which should not end up in the drv
    "derivation"
    "deps"
    "env"
    "final"
  ];

  /*
    Filters out args which potentially must be removed because they are null.
    Later, the ones which are not null will be added back via `argsMaybeIgnored`
  */
  argsCleaned = l.removeAttrs config (argsIgnore);

  argsNotNull = l.filterAttrs (_: val: val != null) argsCleaned;

  # esure that none of the env variables collides with the top-level options
  envChecked =
    l.mapAttrs
    (key: val:
      if config ? ${key}
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
    // argsNotNull
    ;

in {
  config.final.derivation-args = args;
}
