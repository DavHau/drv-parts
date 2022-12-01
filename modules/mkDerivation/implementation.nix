{
  config,
  lib,
  stdenv,
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
    "drvPath"
    "type"
  ];

  # args that should not be passed to mkDerivation if set to null
  argsIgnoreIfNull = [
    # attributes that should not be passed if null
    "args"
    "outputHash"
    "realBuilder"
    "name"
    "pname"
    "version"
    "__contentAddressed"
    "builder"
    "src"
    "srcs"
    "sourceRoot"
    "phases"
    "unpackCmd"

    # phases
    "patchPhase"
    "configurePhase"
    "buildPhase"
    "checkPhase"
    "installPhase"
    "fixupPhase"
    "installCheckPhase"
  ];

  /*
    Filters out args which potentially must be removed because they are null.
    Later, the ones which are not null will be added back via `argsMaybeIgnored`
  */
  argsFiltered = l.removeAttrs config (argsIgnore ++ argsIgnoreIfNull);

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

  # returns empty attrset if value == null
  omitIfNull = argName:
    if config.${argName} == null
    then {}
    else {${argName} = config.${argName};};

  # only contains args for which value != null
  argsMaybeIgnored =
    l.foldl
    (all: argName: all // (omitIfNull argName))
    {}
    argsIgnoreIfNull;

  # all args that are massed directly to mkDerivation
  args =
    envChecked
    // argsFiltered
    // argsMaybeIgnored
    ;

in {
  config.derivation =
    stdenv.mkDerivation args;
}
