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

  # outputs needed to assemble a package as proposed in
  #   https://github.com/NixOS/nix/issues/6507
  outputs = l.unique config.outputs;

  # all args that are passed directly to the final derivation function
  args = finalArgs // envChecked // {inherit outputs;};

  outputDrvs = l.genAttrs outputs
    (output: config.final.package-func-result.${output});

  outputPaths = l.mapAttrs (_: drv: "${drv}") outputDrvs;

  outputDrvsContexts =
    l.mapAttrsToList (output: path: l.getContext path) outputPaths;

  isSingleDrvPackage = (l.length (l.unique outputDrvsContexts)) == 1;

  nonSingleDrvError = ''
    The package ${config.final.package.name} consists of multiple outputs that are built by distinct derivations. It can't be understood as a single derivation.
    This problem is causes by referencing the package directly. Instead, reference one of its output attributes:
      - .${l.concatStringsSep "\n  - ." outputs}
  '';

  throwIfMultiDrvOr = returnVal:
    if isSingleDrvPackage
    then returnVal
    else throw nonSingleDrvError;

  derivation =
    # out, lib, bin, etc...
    outputDrvs
    # outputs, drvPath
    // {
      inherit outputs;
      inherit config extendModules;
      drvPath = throwIfMultiDrvOr outputDrvs.out.drvPath;
      outPath = throwIfMultiDrvOr outputDrvs.out.outPath;
      type = "derivation";
    };

in {

  # add an option for each output, eg. out, bin, lib, etc...
  options.final.package = l.genAttrs config.outputs (output: l.mkOption {
    type = t.path;
  });

  # the final derivation args
  config.final.package-args = args;

  # the final derivation
  config.final.package = derivation;
}
