{
  makeModule,
  nixpkgs,
  pkgs,
  packages
}:
let

  commonModule = {
    /*
      To keep this simple, only a few packages have been converted to modules,
        while the rest is still taken from nixpkgs.
      `// pkgs` can be removed once all packages are modules.
    */
    depsFrom = packages // pkgs;
    stdenv = pkgs.stdenv;
  };

  modulesFor = defaultNixPath: [
    (makeModule defaultNixPath)
    commonModule
  ];

in {

  drvs = {
    /*
      In the following we apply makeModule on existing
        default.nix files from nixpkgs.
      makeModule will read the function args of the given default.nix
        and create options for them.
      From the arg name, it tries to detect if the arg is a bool flag
      If an arg is a flag, like `systemdSupport` it will create a
        module option with the same name.
      If an arg is of not a flag, the user
        is expected to declare it under `deps` which is the field for
        passing in dependencies.
      Flags with weird names cannot be detected as such and therefore must
        be declared under `deps`, despite not representing a dependency.
    */

    # htop defined via submodule
    htop.imports = modulesFor (nixpkgs + /pkgs/tools/system/htop/default.nix);
    lm_sensors.imports = modulesFor (nixpkgs + /pkgs/os-specific/linux/lm-sensors/default.nix);
    ncurses.imports = modulesFor (nixpkgs + /pkgs/development/libraries/ncurses/default.nix);
    bison.imports = modulesFor (nixpkgs + /pkgs/development/tools/parsing/bison/default.nix);
  };
}
