{lib, mkDerivationBackend}:
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

  # create a nixos option for a flag
  makeFlagOptions = args:
    l.mapAttrs
    (argName: hasDefault:
      l.mkOption {
        type = t.bool;
      }
    )
    args;

  # the arguments of the default.nix
  args = (l.functionArgs defaultNixImported);

  # all arguments of the defaut.nix which are flags
  flagArgs = l.filterAttrs (argName: _: isBoolFlag argName) args;

  # all arguments of the default.nix which are package dependencies (mostly)
  depArgs = l.filterAttrs (argName: _: ! flagArgs ? ${argName}) args;

  # generated nixos options for all flags
  flagOptions = makeFlagOptions flagArgs;

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
    else (
      throw ''
        You are trying to generate a module from a legacy default.nix file
          located under ${defaultNix},
          but the `deps` option is not populated with all required dependencies.
        The following dependencies are missing:
          - ${l.concatStringsSep "\n  - " missingDepNames}
      ''
    );

  # removes flags from derivation arguments.
  removeFlags = args:
    l.filterAttrs (argName: _: ! flagArgs ? ${argName}) args;

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

  # overrides a derivation with given arguments
  overrideDrv = drv: args:
    drv.overrideAttrs
    (old:
      l.mapAttrs
      (argName: val: mergeValue argName (old.${argName} or null) val)
      args
    );

in {config, ...}: {

  imports = [mkDerivationBackend ];

  options = flagOptions;

  config = let

    ensuredDeps = ensureDepsPopulated config.deps;

    flagArgs' =
      l.mapAttrs
      (argName: _: config.${argName})
      flagArgs;

    depArgs' = (l.mapAttrs (depName: _: ensuredDeps.${depName}) depArgs);

    # call the default.nix passing only its required arguments (flags + deps);
    derivationOrig =
      defaultNixImported (flagArgs' // depArgs');

    /*
      We need to override the derivation to apply the rest of the mkDerivation
        arguments that might have been defined by the user.
      TODO: There is a problem:
        Some of the derivation args set by the default.nix are now
        overridden with defaults from `/modules/mkDerivation`.

        The root cause of this is likely the custom merging done by `overideDrv`.
        It does not have a clue which of the options are defaults, and which are
          not.
        If we could hand over the merging to the module system, this might
          behave better.
    */
    finalDerivation =
      (overrideDrv derivationOrig (removeFlags config.final.derivation-args));

  in
    {
      deps.lib = lib;
      final.derivation = l.mkForce finalDerivation;
    };
}
