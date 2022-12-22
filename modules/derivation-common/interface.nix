{config, lib, dependencySets, ...}: let
  l = lib // builtins;
  t = l.types;
  callDeps = func: func dependencySets;
  optNullOrBool = l.mkOption {
    type = t.nullOr t.bool;
    default = null;
  };
  optListOfStr = l.mkOption {
    type = t.nullOr (t.listOf t.str);
    default = null;
  };
  optNullOrStr = l.mkOption {
    type = t.nullOr t.str;
    default = null;
  };
  mkFlag = description: l.mkOption {
    inherit description;
    type = t.bool;
    default = false;
  };

  # options forwarded to the final derivation function call
  forwardedOptions = {
    # basic arguments
    args = optListOfStr;
    outputs = optListOfStr;
    __structuredAttrs = lib.mkOption {
      type = t.nullOr t.bool;
      default = null;
    };

    # advanced attributes
    allowedReferences = optListOfStr;
    allowedRequisites = optListOfStr;
    disallowedReferences = optListOfStr;
    disallowedRequisites = optListOfStr;
    exportReferenceGraph = lib.mkOption {
      # TODO: make type stricter
      type = t.nullOr (t.listOf (t.either t.str t.package));
      default = null;
    };
    impureEnvVars = optListOfStr;
    outputHash = optNullOrStr;
    outputHashAlgo = optNullOrStr;
    outputHashMode = optNullOrStr;
    passAsFile = optListOfStr;
    preferLocalBuild = optListOfStr;
    allowSubstitutes = optNullOrBool;
  };

  # drv-parts specific options, not forwardedto the final deirvation call
  drvPartsOptions = {
    argsForward = l.mkOption {
      type = t.attrsOf t.bool;
    };

    /*
      Helper option to define `flags`.
      This makes the syntax for defining flags simpler and at the same time
        prevents users to make mistakes like, for example, defining flags with
        other types than bool.

      This allows flags to be defined like this:
      {
        config.flagsOffered = {
          enableFoo = "builds with foo support";
          ...
        };
      }

      ... instead of this:
      {
        options.flags = {
          enableFoo = l.mkOption {
            type = t.bool;
            description = "builds with foo support";
            default = false;
          };
          ...
        }
      }

    */
    flagsOffered = l.mkOption {
      type = t.attrsOf t.str;
      default = {};
    };

    # The flag options generated from `flagsOffered`
    flags = l.mkOption {
      type = t.submodule {
        options = l.mapAttrs (_: mkFlag) config.flagsOffered;
      };
      default = {};
    };

    final.derivation-args = l.mkOption {
      type = t.attrs;
    };
    # this will be the resulting derivation
    final.derivation = lib.mkOption {
      type = t.package;
    };

    /*
      This allows defining drvs in an encapsulated manner, while maintaining
        the capability to depend on external attributes
    */
    deps = l.mkOption {
      description = ''
        All dependencies of the package. This option should be set by the "outer world" and can be used to inherit attributes from `pkgs` or `inputs` etc.

        By separating the task of retrieving things from the outside world, it is ensured that the dependencies are overridable.
        Nothing will stop users from adding `pkgs` itself as a dependency, but this will make it very hard for the user of the package to override any dependencies, because they'd have to figure out a way to insert their changes into the Nixpkgs fixpoint. By adding specific attributes to `deps` instead, the user has a realistic chance of overriding those dependencies.

        So deps should be specific, but not overly specific. For instance, the caller shouldn't have to know the version of a dependency in order to override it. The name should suffice. (e.g. `nix = nixVersions.nix_2_12` instead of `inherit (nixVersions) nix_2_12`.
      '';
      type =
        t.coercedTo
        (t.functionTo (t.lazyAttrsOf t.raw))
        callDeps
        (t.lazyAttrsOf t.raw);
      default = {};
      example = lib.literalExpression ''
        {pkgs, inputs', ...}: {
          inherit (pkgs) stdenv;
          inherit (pkgs.haskellPackages) pandoc;
          nix = inputs'.nix.packages.default;
        }
      '';
    };

    env = lib.mkOption {
      type = t.attrsOf (t.oneOf [t.bool t.int t.str t.path t.package]);
      default = {};
    };

  };
in {
  config.argsForward = l.mapAttrs (_: _: true) forwardedOptions;
  options = forwardedOptions // drvPartsOptions;
}
