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

  # outputs needed to assemble the package
  outputs = config.final.outputs;

  # all args that are passed directly to the final derivation function
  args = finalArgs // envChecked // {inherit outputs;};

  drvFuncResult = config.final.derivation-func config.final.derivation-args;

  outputDrvs = l.genAttrs outputs (output: drvFuncResult.${output});
  outputPaths = l.genAttrs outputs (output: "${drvFuncResult.${output}}");
  outputDrvsContexts = l.mapAttrsToList (output: path: l.getContext path) outputPaths;

  packageIdentifier =
    if drvFuncResult ? name
    then drvFuncResult.name
    else if config.pname != null
    then "${config.pname}-${config.version}"
    else config.name;

  isSingleDrvPackage = (l.length (l.unique outputDrvsContexts)) == 1;

  nonSingleDrvError = ''
    The package ${packageIdentifier} consists of multiple outputs that are built by distinct derivations. It can't be understood as a single derivation.
    This problem is cause by referencing the package directly. Instead reference one of its output attributes:
      - .${l.concatStringsSep "\n  - ." outputs}
  '';

  drvPath =
    if isSingleDrvPackage
    then outputDrvs.out.drvPath
    else throw nonSingleDrvError;

  outPath =
    if isSingleDrvPackage
    then outputDrvs.out.outPath
    else throw nonSingleDrvError;

  package =
    # out, lib, bin, etc...
    outputDrvs
    # name, version, outputs, drvPath
    // {
      inherit drvPath outputs outPath;
      inherit (config) version;
      name = packageIdentifier;
      type = "derivation";
    };

in {

  # the final derivation args
  config.final.derivation-args = args;

  # the final derivation
  config.final.derivation = package;

  # outputs needed to assemble a package as proposed in
  #   https://github.com/NixOS/nix/issues/6507
  config.final.outputs = l.mkDefault (l.unique config.outputs);
}
