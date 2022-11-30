{config, lib, ...}: let
  l = lib // builtins;
  t = l.types;
in {
  options = {

    # this will be the resulting derivation
    derivation = lib.mkOption {
      type = t.package;
    };
    drvPath = lib.mkOption {
      type = t.package;
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
