{config, lib, ...}: let
  l = lib // builtins;
  t = l.types;
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
  # make option for a given dependency name
  mkDepOpt = depName: _: l.mkOption {
    description = ''
      Specify a package for the dependency ${depName}.
      By default `config.depsFrom.${depName}` is used.
    '';
    type = t.raw;
    default = config.depsFrom.${depName};
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

    depsRequired = l.mkOption {
      type = t.attrsOf t.bool;
      default = {};
    };

    /*
      Attrset of required dependencies.
      For example, when `config.depsRequired.bash = true`, then this creates:
      {
        options.deps = l.mkOption {
          description = "spcify a package for the dependency bash"
          type = t.raw;
          default = config.fromDeps.bash;
        }
      }
    */
    deps =
      l.mapAttrs
      mkDepOpt
      (l.filterAttrs (_: enabled: enabled) config.depsRequired);

    # Unspecified `deps` are taken from `depsFrom`. It's a source for defaults.
    depsFrom = l.mkOption {
      description = "Package set to populate unspecified `deps`";
      type = t.lazyAttrsOf t.raw;
      default = {};
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
