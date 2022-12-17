{config, lib, stdenv, nixpkgsConfig, ...}: let
  l = lib // builtins;
  t = l.types;
  optNullOrStr = l.mkOption {
    type = t.nullOr t.str;
    default = null;
  };
  optList = l.mkOption {
    type = t.nullOr (t.listOf t.anything);
    default = null;
  };
  optListOfStr = l.mkOption {
    type = t.nullOr (t.listOf t.str);
    default = null;
  };
  optAttrs = l.mkOption {
    type = t.nullOr (t.attrs);
    default = {};
  };
  optNullOrBool = l.mkOption {
    type = t.nullOr t.bool;
    default = null;
  };
  optPackage = l.mkOption {
    type = t.nullOr (t.oneOf [t.str t.path t.package]);
    default = null;
  };
  optPackageList = l.mkOption {
    type = t.nullOr (t.listOf (t.oneOf [t.str t.path t.package]));
    default = null;
  };

in rec {
  imports = [
    ../derivation-common
  ];

  # signal that all options should be passed to the final derivation function
  config.argsForward = l.mapAttrs (_: _: true) options;

  options = {

    # from derivation
    builder = optPackage;
    __contentAddressed = optNullOrBool;

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
    configurePlatforms = optList;
    doCheck = optNullOrBool;
    doInstallCheck = optNullOrBool;
    strictDeps = optNullOrBool;
    enableParallelBuilding = optNullOrBool;
    meta = optAttrs;
    passthru  = optAttrs;
    pos = optAttrs;
    separateDebugInfo = optNullOrBool;
    __darwinAllowLocalNetworking = optNullOrBool;
    __impureHostDeps = optList;
    __propagatedImpureHostDeps = optList;
    sandboxProfile = optNullOrStr;
    propagatedSandboxProfile = optNullOrStr;
    hardeningEnable = optList;
    hardeningDisable = optList;
    patches = optList;


    # make-derivation args - without defaults
    enableParallelChecking = optNullOrBool;
    name = optNullOrStr;
    pname = optNullOrStr;
    realBuilder = optPackage;
    requiredSystemFeatures = optListOfStr;
    version = optNullOrStr;

    # setup.sh phase lists
    phases = optListOfStr;
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
    dontUnpack = optNullOrBool;
    dontPatch = optNullOrBool;
    dontConfigure = optNullOrBool;
    dontBuild = optNullOrBool;
    dontInstall = optNullOrBool;
    dontFixup = optNullOrBool;
    doDist = optNullOrBool;

    # unpack phase
    src = optPackage;
    srcs = optPackageList;
    sourceRoot = optPackage;
    setSourceRoot = optNullOrStr;
    dontMakeSourcesWritable = optNullOrBool;
    unpackCmd = optNullOrStr;

    # patch phase
    patchFlags = optNullOrStr;

    # configure phase
    configureScript = optNullOrStr;
    dontAddPrefix = optNullOrBool;
    prefix = optNullOrStr;
    prefixKey = optNullOrStr;
    dontAddStaticConfigureFlags = optNullOrBool;
    dontAddDisableDepTrack = optNullOrBool;
    dontFixLibtool = optNullOrBool;
    dontDisableStatic = optNullOrBool;

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
    dontStrip = optNullOrBool;
    dontStripHost = optNullOrBool;
    dontStripTarget = optNullOrBool;
    dontMoveBin = optNullOrBool;
    stripAllList = optList;
    stripAllFlags = optList;
    stripDebugList = optList;
    stripDebugFlags = optList;
    dontPatchELF = optNullOrBool;
    dontPatchShebangs = optNullOrBool;
    dontPruneLibtoolFiles = optNullOrBool;
    forceShare = optList;
    setupHook = optPackage;

    # installCheck phase
    installCheckTarget = optNullOrStr;
    installCheckFlags = optList;

    # distribution phase
    distTarget = optNullOrStr;
    distFlags = optList;
    tarballs = optList;
    dontCopyDist = optNullOrBool;
  };
}
