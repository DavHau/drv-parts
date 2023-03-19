{lib}:
{
  # packageFunc can be:
  #   - a package function
  #       (eg: {stdenv, depXY, enableFoo}: stdenv.mkDerivation {...})
  #   - or a path to a package function file (eg. default.nix file)
  #   - or something that offers an override function
  packageFunc,

  # pass extra modules to include by default
  modules ? [],
  ...
} @ arguments: let

  l = lib // builtins;
  t = l.types;

  packageFunc =
    if l.isDerivation arguments.packageFunc
    then ({...}: arguments.packageFunc)
    else if l.isFunction arguments.packageFunc
    then arguments.packageFunc
    else import arguments.packageFunc;

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
  args = (l.functionArgs packageFunc);

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

in {config, options, extendModules, ...}: {

  imports =
    (l.toList modules)
    ++ [
      ../modules/drv-parts/mkDerivation/interface.nix
      ../modules/drv-parts/core
    ];

  options.flags = flagOptions;
  options.deps = l.mapAttrs mkDepOpt depArgs;
  options.public.drvAttrs = l.mkOption {
    type = t.lazyAttrsOf t.raw;
  };

  config = let

    topLevelOptions = l.filterAttrs (name: _: name != "_module") options.mkDerivation;

    pickFlag = flagName: _: config.flags.${flagName};
    pickDep = depName: _: config.deps.${depName};
    flagArgs' = l.mapAttrs pickFlag flagArgs;
    depArgs' = l.mapAttrs pickDep depArgs;

    # the arguments required to call the given default.nix style package func.
    packageFunctionArgs = flagArgs' // depArgs';

    # call the package func passing only its required arguments (flags + deps);
    derivationOrig = packageFunc packageFunctionArgs;

    # the arguments passed to mkDerivation by the default.nix package func
    origMkDrvArgs = getMkDrvArgs derivationOrig;

    # Returns true if a given argName is a top-level config field for drv-parts'
    #   mkDerivation.
    isTopLevelArg = argName: _: topLevelOptions ? ${argName};

    # all mkDerivation args originating from the default.nix func
    origMkDrvArgsTopLevel = l.filterAttrs isTopLevelArg origMkDrvArgs;
    # all env variables originating from the default.nix func
    origMkDrvArgsEnv =
      l.filterAttrs (argName: _: ! origMkDrvArgsTopLevel ? ${argName}) origMkDrvArgs;

    # modules for the mkDerivation and env args originating from the default.nix
    origMkDrvArgsModule = {config.mkDerivation = origMkDrvArgsTopLevel;};
    origMkDrvEnvModule = {config.env = origMkDrvArgsEnv;};

    # Restore priorities of user specified config.
    # This is necessary becaue `config.mkDerivation` is forwarded into a second
    #   module evaluation.
    # To regain proper merging, priorities have to be restored first.
    mkUserConfigOverride = argName: _:
      l.mkOverride options.mkDerivation.${argName}.highestPrio
      config.mkDerivation.${argName};

    # a copy of all user defined args for drv-part's mkDerivation including the
    # priority (this is required to merge once more in finalDrvModule)
    userArgsModule = {
      config.mkDerivation = l.mapAttrs mkUserConfigOverride topLevelOptions;
      config.flags = config.flags;
    };
    userEnvModule = {config.env = config.env;};

    # drv-parts strictly requires name + version. If the original derivation
    #   only specified a `name` but no `version` or `pname`, we have to recover
    #   name and version from the original `name` by splitting it.
    origNameSplit = l.splitString "-" origMkDrvArgs.name;
    finalVersion =
      if origMkDrvArgs ? version
      then origMkDrvArgs.version
      else l.last origNameSplit;
    finalName =
      if origMkDrvArgs ? pname
      then origMkDrvArgs.pname
      else l.removeSuffix finalVersion origMkDrvArgs.name;

    # nested drv-parts evaluation to include the mkDerivation arguments
    # extracted from the default.nix package func
    finalDrvModule = {
      imports = [
        ../modules/drv-parts/mkDerivation
        ../modules/drv-parts/core
        origMkDrvArgsModule
        origMkDrvEnvModule
        userArgsModule
        userEnvModule
      ];
      _file = "finalDrvModule";
      options = flagOptions;
      config.deps.stdenv = config.deps.stdenv;
      config.name = finalName;
      config.version = finalVersion;
    };

    finalDrvEval = l.evalModules {
      modules = [finalDrvModule];
      specialArgs.dependencySets = {};
    };

    finalDerivation = finalDrvEval.config.public;

    outputDrvs = l.genAttrs finalDerivation.outputs
      (output: finalDerivation.${output});

    public =
      # out, lib, bin, etc...
      outputDrvs
      # outputs, drvPath
      // {
        inherit (finalDerivation) name version drvPath outPath outputs;
        inherit config extendModules;
        drvAttrs = finalDrvEval.config.package-func.result.drvAttrs;
        type = "derivation";
      };

    /*
      Populate deps with some defaults.
      `lib` should be taken from the current module.
      `stdenv` should be taken from `config.deps.stdenv`.
    */
    deps' = {
      inherit lib;
      inherit (config.deps) stdenv;
    };
    deps'' = l.intersectAttrs depArgs deps';
    deps = l.mapAttrs (_: dep: l.mkDefault dep) deps'';

  in

  {
    deps = deps;

    name = l.mkDefault finalDerivation.name;
    version = l.mkDefault finalDerivation.version;

    # we ignore the args as the derivation is computed elsewhere
    public = public;
  };
}
