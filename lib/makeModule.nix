{lib, drvPartsLib}:
defaultNix: let
  l = lib // builtins;
  t = l.types;

  defaultNixImported = import defaultNix;

  isMatch = regex: str: (l.match regex str) != null;

  # determine if an argument is a flag by looking at its name.
  isBoolFlag = argName:
    (isMatch ''with[A-Z].*'' argName)
    || (isMatch ''enable[A-Z].*'' argName)
    || (isMatch ''for[A-Z].*'' argName)
    || (isMatch ".*Support" argName);

  # creates an option of type bool
  mkBoolOption = flagName: _: l.mkOption {type = t.bool;};

  # creates bool options for a set of flags
  makeFlagOptions = l.mapAttrs mkBoolOption;

  # the arguments of the default.nix
  args = (l.functionArgs defaultNixImported);

  # all arguments of the defaut.nix which are flags
  flagArgs = l.filterAttrs (argName: _: isBoolFlag argName) args;

  # all arguments of the default.nix which are package dependencies (mostly)
  depArgs = l.filterAttrs (argName: _: ! flagArgs ? ${argName}) args;

  # generated nixos options for all flags
  flagOptions = makeFlagOptions flagArgs;

  # throws error listing missing deps.xxx entries
  throwMissingDepsError = missingDepNames: throw ''
    You are trying to generate a module from a legacy default.nix file
      located under ${defaultNix},
      but the `deps` option is not populated with all required dependencies.
    The following dependencies are missing:
      - ${l.concatStringsSep "\n  - " missingDepNames}
  '';

  # Ensure that all required default.nix dependencies are passed via `deps`.
  # This is a bit hacky. It would be nicer if we could define `deps.{foo}`
  #   as an individual option, but `deps` is already defined as `coercedTo`
  #   which does not support nested options.
  ensureDepsPopulated = deps: let
    missingDeps = l.filterAttrs (depName: _: ! deps ? ${depName}) depArgs;
    missingDepNames = l.attrNames missingDeps;
  in
    if missingDeps == {}
    then deps
    else throwMissingDepsError missingDepNames;

  # override func that exposes mkDerivation arguments
  passthruMkDrvArgs = oldArgs: {passthru.__mkDrvArgs = oldArgs;};

  getMkDrvArgs = drv: (drv.overrideAttrs passthruMkDrvArgs).__mkDrvArgs;

in {config, options, ...}: {

  imports = [../modules/mkDerivation/interface.nix];

  options = flagOptions;

  config = let

    # raises errors if a dependency is missing from `config.deps`
    ensuredDeps = ensureDepsPopulated config.deps;

    pickFlag = flagName: _: config.${flagName};
    pickDep = depName: _: ensuredDeps.${depName};
    flagArgs' = l.mapAttrs pickFlag flagArgs;
    depArgs' = l.mapAttrs pickDep depArgs;

    # the arguments required to call the given default.nix style package func.
    packageFunctionArgs = flagArgs' // depArgs';

    # call the package func passing only its required arguments (flags + deps);
    derivationOrig = defaultNixImported packageFunctionArgs;

    # the arguments passed to mkDerivation by the default.nix package func
    origMkDrvArgs = getMkDrvArgs derivationOrig;

    # Returns true if a given argName is a top-level config field for drv-parts'
    #   mkDerivation.
    isTopLevelArg = argName: _: config.argsForward ? ${argName};

    # all mkDerivation args originating from the default.nix func
    origMkDrvArgsTopLevel = l.filterAttrs isTopLevelArg origMkDrvArgs;
    # all env variables originating from the default.nix func
    origMkDrvArgsEnv =
      l.filterAttrs (argName: _: ! origMkDrvArgsTopLevel ? ${argName}) origMkDrvArgs;

    # modules for the mkDerivation and env args originating from the default.nix
    origMkDrvArgsModule = {config = origMkDrvArgsTopLevel;};
    origMkDrvEnvModule = {config.env = origMkDrvArgsEnv;};

    # all top-level args for drv-part's mkDerivation to map over.
    allUserArgs = config.argsForward // flagArgs;

    mkUserConfigOverride = argName: _:
      l.mkOverride options.${argName}.highestPrio config.${argName};
    # a copy of all user defined args for drv-part's mkDerivation including the
    # priority (this is required to merge once more in finalDrvModule)
    userConfig = l.mapAttrs mkUserConfigOverride allUserArgs;
    userArgsModule = {config = userConfig;};
    userEnvModule = {config.env = config.env;};

    # nested drv-parts evaluation to include the mkDerivation arguments
    # extracted from the default.nix package func
    finalDrvModule = {
      imports = [
        ../modules/mkDerivation
        origMkDrvArgsModule
        origMkDrvEnvModule
        userArgsModule
        userEnvModule
      ];
      _file = "finalDrvModule";
      options = flagOptions;
      config.stdenv = config.stdenv;
    };

    finalDerivation = drvPartsLib.derivationFromModules [finalDrvModule];

  in

  {
    deps.lib = lib;
    final.derivation = finalDerivation;
  };
}
