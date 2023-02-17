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

  # override func that exposes mkDerivation arguments
  passthruMkDrvArgs = oldArgs: {passthru.__mkDrvArgs = oldArgs;};

  getMkDrvArgs = drv: (drv.overrideAttrs passthruMkDrvArgs).__mkDrvArgs;

  mkDepOpt = depName: _: l.mkOption {
    description = "Specify a package for the dependency ${depName}.";
    type = t.raw;
  };

in {config, options, ...}: {

  imports = [
    ../modules/derivation-common
    ../modules/mkDerivation/interface.nix
  ];

  options.flags = flagOptions;
  options.deps = l.mapAttrs mkDepOpt depArgs;

  config = let

    pickFlag = flagName: _: config.flags.${flagName};
    pickDep = depName: _: config.deps.${depName};
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

    finalDerivation = drvPartsLib.derivationFromModules {} [finalDrvModule];

    /*
      Populate deps with some defaults.
      `lib` should be taken from the current module.
      `stdenv` should be taken from `config.stdenv`.
    */
    deps' = {
      inherit lib;
      inherit (config) stdenv;
    };
    deps'' = l.intersectAttrs depArgs deps';
    deps = l.mapAttrs (_: dep: l.mkDefault dep) deps'';

  in

  {
    deps = deps;

    # we ignore the args as the derivation is computed elsewhere
    final.outputs = finalDerivation.outputs;
    final.derivation-func = args: finalDerivation;
  };
}
