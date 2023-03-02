{
  config,
  lib,
  ...
}: let
  l = lib // builtins;
  t = l.types;

  cfg = config.mkDerivation;

  outputs = l.unique cfg.outputs;

  keepArg = key: val: val != null;

  finalArgs = l.filterAttrs keepArg cfg;

  # ensure that none of the env variables collide with the top-level options
  envChecked =
    l.mapAttrs
    (key: val:
      if config.mkDerivation.${key} or false
      then throw (envCollisionError key)
      else val)
    config.env;

  # generates error message for env variable collision
  envCollisionError = key: ''
    Error while evaluating definitions for derivation ${config.public.name}
    The environment variable defined via `env.${key}' collides with the top-level option `${key}'.
    Specify the top-level option instead, or rename the environment variable.
  '';

  name =
    if cfg.pname != null
    then "${cfg.pname}-${cfg.version}"
    else if cfg.name != null
    then cfg.name
    else if cfg.final.package-func-result ? name
    then cfg.final.package-func-result.name
    else throw "Cannot determine package name";

  derivation =
    {
      inherit name;
    }
    # meta
    // (l.optionalAttrs (cfg.passthru ? meta) {
      inherit (cfg.passthru) meta;
    })
    # tests
    // (l.optionalAttrs (cfg.passthru ? tests) {
      inherit (cfg.passthru) tests;
    });

in {
  imports = [
    ../pkg-func/implementation.nix
  ];

  config.final.outputs = cfg.outputs;

  config.final.package-func = lib.mkDefault config.deps.stdenv.mkDerivation;

  # add mkDerivation specific derivation attributes
  config.public = derivation;

  config.final.package-args = envChecked // finalArgs // {inherit outputs;};
}
