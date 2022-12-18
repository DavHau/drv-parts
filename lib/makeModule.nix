{lib}:
defaultNix: let
  l = lib // builtins;
  t = l.types;

  defaultNixImported = import defaultNix;

  # determine if an argument is a flag by looking at its name.
  isBoolFlag = argName:
    (l.hasPrefix "with" argName)
    || (l.hasPrefix "enable" argName)
    || (l.hasPrefix "for" argName)
    || (l.hasSuffix "Support" argName);

  mkFlagOption = flagName: _: l.mkOption {type = t.bool;};

  # create a nixos option for a flag
  makeFlagOptions = l.mapAttrs mkFlagOption;

  # the arguments of the default.nix
  args = (l.functionArgs defaultNixImported);

  # all arguments of the defaut.nix which are flags
  flagArgs = l.filterAttrs (argName: _: isBoolFlag argName) args;

  # all arguments of the default.nix which are package dependencies (mostly)
  depArgs = l.filterAttrs (argName: _: ! flagArgs ? ${argName}) args;

  # generated nixos options for all flags
  flagOptions = makeFlagOptions flagArgs;

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

  # TODO: Can we use the module system's merge logic here instead?
  mergeValue = name: a: b:
    if a == null
    then b
    else if b == null
    then a
    else if l.isList a
    then l.unique (a ++ b)
    else if l.isAttrs a
    then a // b
    else b;

  mergeDrvArgs = args: oldArgs:
    l.mapAttrs
    (argName: val: mergeValue argName (oldArgs.${argName} or null) val)
    args;

  # overrides a derivation with given arguments
  overrideDrv = drv: args:
    drv.overrideAttrs
    (old: mergeDrvArgs args old);

in {config, ...}: {

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

    # override the derivation produced by the package func with the values
    # coming from the package module.
    finalDerivation =
      (overrideDrv derivationOrig config.final.derivation-args);

  in
    {
      deps.lib = lib;
      final.derivation = finalDerivation;
    };
}
