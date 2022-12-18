{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    drv-parts.url = "github:DavHau/drv-parts";
    drv-parts.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    flake-parts,
    drv-parts,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit self;} {
      systems = ["x86_64-linux"];

      # enable the drv-parts plugin for flake-parts
      imports = [drv-parts.flakeModule];

      perSystem = {config, lib, pkgs, self', ...}: {
        checks = config.packages;

        drvs = let
          inherit (drv-parts.lib) makeModule;

          depsFromNixpkgs = {
            inherit (pkgs)
              # some of these packages could also be ported to drv-parts via
              # makeModule, but for demonstration purposes, we want to keep the
              # list short, and inherit them from nixpkgs instead.
              autoreconfHook
              binutils
              fetchurl
              fetchFromGitHub
              stdenv
              IOKit
              forFHSEnv
              util-linux
              help2man
              m4
              perl
              flex
              which
              pkg-config
              gpm
              libintl
              procps
              xz
              ;
            buildPackages.perl = pkgs.perl;
            buildPackages.stdenv.cc = pkgs.buildPackages.stdenv.cc;
            # this can be null because we set `htop.systemdSupport = false`
            systemd = null;
          };

          allDeps = self'.packages // depsFromNixpkgs;

          commonModule = {
            deps = allDeps;
            stdenv = pkgs.stdenv;
          };

        in {

          /*
            In the following we apply makeModule on existing
              default.nix files from nixpkgs.
            makeModule will read the function args of the given default.nix
              and create options for them.
            From the arg name, it tries to detect if the arg is of type
              bool.
            If an arg is of type bool, like `systemdSupport` it will create a
              nixos module option appropriately
            If an arg is of not of type bool, the user
              is expected to declare it under `deps` which is the field for
              passing in dependencies.
            Bool flags with weird names, therefore mustbe declared via `deps`,
              despite not being an actual dependency.
          */

          # htop defined via submodule
          htop.imports = [commonModule (makeModule (nixpkgs + /pkgs/tools/system/htop/default.nix))];
          # these options have been generated automatically by `makeModule`
          htop.systemdSupport = false;
          htop.sensorsSupport = true;

          lm_sensors.imports = [commonModule (makeModule (nixpkgs + /pkgs/os-specific/linux/lm-sensors/default.nix))];
          # `sensord` and `rrdtool` are bool flags, but because of their maes,
          #   makeModule detected them as dependencies.
          lm_sensors.deps.sensord = false;
          lm_sensors.deps.rrdtool = null;

          ncurses.imports = [commonModule (makeModule (nixpkgs + /pkgs/development/libraries/ncurses/default.nix))];
          ncurses.deps.abiVersion = "6";
          ncurses.mouseSupport = false;
          ncurses.unicodeSupport = true;
          ncurses.withCxx = true;
          ncurses.enableStatic = false;

          bash.imports = [commonModule (makeModule (nixpkgs + /pkgs/shells/bash/5.1.nix))];
          bash.deps.interactive = false;
          bash.withDocs = false;
          bash.forFHSEnv = false;

          texinfo.imports = [commonModule (makeModule (nixpkgs + /pkgs/development/tools/misc/texinfo/6.8.nix))];
          texinfo.deps.interactive = false;

          bison.imports = [commonModule (makeModule (nixpkgs + /pkgs/development/tools/parsing/bison/default.nix))];
          readline81.imports = [commonModule (makeModule (nixpkgs + /pkgs/development/libraries/readline/8.1.nix))];
        };
      };
    };
}
