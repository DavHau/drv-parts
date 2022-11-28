{config, lib, pkgs, nixpkgsConfig, ...}: let
  l = lib // builtins;
  t = l.types;
  stdenv = pkgs.stdenv;
  mkOpt = type: l.mkOption {inherit type;};
  optNullOrStr = l.mkOption {
    type = t.nullOr t.str;
    default = null;
  };
  optList = l.mkOption {
    type = t.listOf t.anything;
    default = [];
  };
  optAttrs = l.mkOption {
    type = t.attrs;
    default = {};
  };
  optBoolWithDefault = default: l.mkOption {
    type = t.bool;
    inherit default;
  };
in {
  imports = [
    ../derivation-common
  ];
  options = {
    # from derivation
    builder = l.mkOption {
      type = t.nullOr (t.oneOf [t.str t.path t.package]);
      default = null;
    };
    __contentAddressed = lib.mkOption {
      type = t.nullOr t.bool;
      default = null;
    };

    # defaultEmptyList
    depsBuildBuild = optList;
    depsBuildBuildPropagated = optList;
    nativeBuildInputs = optList;
    propagatedNativeBuildInputs = optList;
    depsBuildTarget = optList;
    depsBuildTargetPropagated = optList;
    depsHostHost = optList;
    depsHostHostPropagated = optList;
    buildInputs = optList;
    propagatedBuildInputs = optList;
    depsTargetTarget = optList;
    depsTargetTargetPropagated = optList;
    checkInputs = optList;
    installCheckInputs = optList;
    configureFlags = optList;
    cmakeFlags = optList;
    mesonFlags = optList;
    configurePlatforms = l.mkOption {
      type = t.listOf t.anything;
      default = l.optionals
        (stdenv.hostPlatform != stdenv.buildPlatform
          # TODO: This expression from nixpkgs had to be modified.
          # investigate why `or false` is not required in nixpkgs
          || nixpkgsConfig.configurePlatformsByDefault or false)
        [ "build" "host" ];
    };
    doCheck = optBoolWithDefault nixpkgsConfig.doCheckByDefault or false;
    doInstallCheck = optBoolWithDefault nixpkgsConfig.doCheckByDefault or false;
    strictDeps = optBoolWithDefault
      (if nixpkgsConfig.strictDepsByDefault
      then true
      else stdenv.hostPlatform != stdenv.buildPlatform);
    enableParallelBuilding =
      optBoolWithDefault nixpkgsConfig.enableParallelBuildingByDefault;
    meta = optAttrs;
    passthru  = optAttrs;
    pos = l.mkOption {
      type = t.nullOr t.str;
      default =
        # TODO: this seems to be null by default, but probably shouldn't !?
        # position used in error messages and for meta.position
        (if config.meta.description or null != null
          then builtins.unsafeGetAttrPos "description" config.meta
          else if config.version or null != null
          then builtins.unsafeGetAttrPos "version" config
          else builtins.unsafeGetAttrPos "name" config);
    };
    separateDebugInfo = optBoolWithDefault false;
    __darwinAllowLocalNetworking = optBoolWithDefault false;
    __impureHostDeps = optList;
    __propagatedImpureHostDeps = optList;
    sandboxProfile = l.mkOption {
      type = t.str;
      default = "";
    };
    propagatedSandboxProfile = l.mkOption {
      type = t.str;
      default = "";
    };
    hardeningEnable = optList;
    hardeningDisable = optList;
    patches = optList;


    # without defaults
    enableParallelChecking = optBoolWithDefault true;
    pname = l.mkOption {
      type = t.nullOr t.str;
      default = null;
    };
    realBuilder = l.mkOption {
      type = t.nullOr (t.oneOf [t.str t.path t.package]);
      default = null;
    };
    requiredSystemFeatures = l.mkOption {
      type = t.listOf t.str;
      default = [];
    };
    version = l.mkOption {
      type = t.nullOr t.str;
      default = null;
    };

    # setup.sh phase lists
    phases = l.mkOption {
      type = t.nullOr (t.listOf t.str);
      default = null;
    };
    prePhases = optList;
    preConfigurePhases = optList;
    preBuildPhases = optList;
    preInstallPhases = optList;
    preFixupPhases = optList;
    preDistPhases = optList;
    postPhases = optList;

    # unpack phase variables
    sourceRoot = l.mkOption {
      type = t.nullOr (t.oneOf [t.str t.path t.package]);
      default = null;
    };
    src = l.mkOption {
      type = t.nullOr (t.oneOf [t.str t.path t.package]);
      default = null;
    };
    srcs = l.mkOption {
      type = t.nullOr (t.listOf (t.oneOf [t.str t.path t.package]));
      default = null;
    };

    # setup.sh phases
    unpackPhase = optNullOrStr;
    preUnpack = optNullOrStr;
    postUnpack = optNullOrStr;
    dontMakeSourcesWritable = optBoolWithDefault false;
    unpackCmd = optNullOrStr;

    patchPhase = optNullOrStr;
    configurePhase = optNullOrStr;
    buildPhase = optNullOrStr;
    checkPhase = optNullOrStr;
    installPhase = optNullOrStr;
    fixupPhase = optNullOrStr;
    installCheckPhase = optNullOrStr;

    # setup.sh flags
    dontUnpack = optBoolWithDefault false;
    dontPatch = optBoolWithDefault false;
    dontConfigure = optBoolWithDefault false;
    dontBuild = optBoolWithDefault false;
    distPhase = optBoolWithDefault false;
    dontInstall = optBoolWithDefault false;
    dontFixup = optBoolWithDefault false;
    doDist = optBoolWithDefault false;


  };
}
