{config, lib, stdenv, nixpkgsConfig, ...}: let
  l = lib // builtins;
  t = l.types;
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

    # make-derivation args - defaultEmptyList
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


    # make-derivation args - without defaults
    enableParallelChecking = optBoolWithDefault true;
    name = l.mkOption {
      type = t.nullOr t.str;
      default = null;
    };
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

    # setup.sh phases
    unpackPhase = optNullOrStr;
    preUnpack = optNullOrStr;
    postUnpack = optNullOrStr;
    patchPhase = optNullOrStr;
    prePatch = optNullOrStr;
    postPatch = optNullOrStr;
    configurePhase = optNullOrStr;
    preConfigure = optNullOrStr;
    postConfigure = optNullOrStr;
    buildPhase = optNullOrStr;
    preBuild = optNullOrStr;
    postBuild = optNullOrStr;
    checkPhase = optNullOrStr;
    preCheck = optNullOrStr;
    postCheck = optNullOrStr;
    installPhase = optNullOrStr;
    preInstall = optNullOrStr;
    postInstall = optNullOrStr;
    fixupPhase = optNullOrStr;
    preFixup = optNullOrStr;
    postFixup = optNullOrStr;
    installCheckPhase = optNullOrStr;
    preInstallCheck = optNullOrStr;
    postInstalCheck = optNullOrStr;
    distPhase = optNullOrStr;
    preDist = optNullOrStr;
    postDist = optNullOrStr;

    # setup.sh flags
    dontUnpack = optBoolWithDefault false;
    dontPatch = optBoolWithDefault false;
    dontConfigure = optBoolWithDefault false;
    dontBuild = optBoolWithDefault false;
    dontInstall = optBoolWithDefault false;
    dontFixup = optBoolWithDefault false;
    doDist = optBoolWithDefault false;

    # unpack phase
    src = l.mkOption {
      type = t.nullOr (t.oneOf [t.str t.path t.package]);
      default = null;
    };
    srcs = l.mkOption {
      type = t.nullOr (t.listOf (t.oneOf [t.str t.path t.package]));
      default = null;
    };
    sourceRoot = l.mkOption {
      type = t.nullOr (t.oneOf [t.str t.path t.package]);
      default = null;
    };
    setSourceRoot = optNullOrStr;
    dontMakeSourcesWritable = optBoolWithDefault false;
    unpackCmd = optNullOrStr;

    # patch phase
    patchFlags = optNullOrStr;

    # configure phase
    configureScript = optNullOrStr;
    dontAddPrefix = optBoolWithDefault false;
    prefix = optNullOrStr;
    prefixKey = optNullOrStr;
    dontAddStaticConfigureFlags = optBoolWithDefault false;
    dontAddDisableDepTrack = optBoolWithDefault false;
    dontFixLibtool = optBoolWithDefault false;
    dontDisableStatic = optBoolWithDefault false;

    # build phase
    makefile = optNullOrStr;
    makeFlags = optList;
    buildFlags = optList;

    # check phase
    checkTarget = optNullOrStr;
    checkFLags = optList;

    # install phase
    installTargets = optNullOrStr;
    installFlags = optList;

    # fixup phase
    dontStrip = optBoolWithDefault false;
    dontStripHost = optBoolWithDefault false;
    dontStripTarget = optBoolWithDefault false;
    dontMoveBin = optBoolWithDefault false;
    stripAllList = optList;
    stripAllFlags = optList;
    stripDebugList = optList;
    stripDebugFlags = optList;
    dontPatchELF = optBoolWithDefault false;
    dontPatchShebangs = optBoolWithDefault false;
    dontPruneLibtoolFiles = optBoolWithDefault false;
    forceShare = optList;
    setupHook = l.mkOption {
      type = t.nullOr t.path;
      default = null;
    };

    # installCheck phase
    installCheckTarget = optNullOrStr;
    installCheckFlags = optList;

    # distribution phase
    distTarget = optNullOrStr;
    distFlags = optList;
    tarballs = optList;
    dontCopyDist = optBoolWithDefault false;
  };
}
