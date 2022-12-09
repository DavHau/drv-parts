{config, lib, dependencySets ? {}, ...}: let
  l = lib // builtins;
  t = l.types;
  callDeps = func: func dependencySets;
in {
  options = {

    # this will be the resulting derivation
    derivation = lib.mkOption {
      type = t.package;
    };
    drvPath = lib.mkOption {
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

    # basic arguments
    args = lib.mkOption {
      type = t.nullOr (t.listOf t.str);
      default = null;
    };
    env = lib.mkOption {
      type = t.attrsOf (t.oneOf [t.bool t.int t.str t.path t.package]);
      default = {};
    };
    outputs = lib.mkOption {
      type = t.listOf t.str;
      default = ["out"];
    };
    system = lib.mkOption {
      type = t.str;
    };
    __structuredAttrs = lib.mkOption {
      type = t.nullOr t.bool;
      default = false;
    };

    # advanced attributes
    allowedReferences = lib.mkOption {
      type = t.nullOr (t.listOf t.str);
      default = null;
    };
    allowedRequisites = lib.mkOption {
      type = t.nullOr (t.listOf t.str);
      default = null;
    };
    disallowedReferences = lib.mkOption {
      type = t.nullOr (t.listOf t.str);
      default = null;
    };
    disallowedRequisites = lib.mkOption {
      type = t.nullOr (t.listOf t.str);
      default = null;
    };
    exportReferenceGraph = lib.mkOption {
      # TODO: make type stricter
      type = t.listOf (t.either t.str t.package);
      default = [];
    };
    impureEnvVars = lib.mkOption {
      type = t.listOf t.str;
      default = [];
    };
    outputHash = lib.mkOption {
      type = t.nullOr t.str;
      default = null;
    };
    outputHashAlgo = lib.mkOption {
      type = t.nullOr t.str;
      default = "sha256";
    };
    outputHashMode = lib.mkOption {
      type = t.nullOr t.str;
      default = "recursive";
    };
    passAsFile = lib.mkOption {
      type = t.listOf t.str;
      default = [];
    };
    preferLocalBuild = lib.mkOption {
      type = t.bool;
      default = false;
    };
    allowSubstitutes = lib.mkOption {
      type = t.bool;
      default = true;
    };
  };
}
