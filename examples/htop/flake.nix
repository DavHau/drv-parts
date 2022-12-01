{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    drv-parts.url = "nixpkgs";
  };

  outputs = {
    self,
    flake-parts,
    drv-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit self;} {
      systems = ["x86_64-linux"];

      # enable the drv-parts plugin for flake-parts
      imports = [drv-parts.flakeModule];

      perSystem = {config, lib, pkgs, ...}: {
        checks = config.packages;
        drvs.htop = {
          imports = [./htop.nix];
          deps = {
            inherit (pkgs)
              autoreconfHook
              fetchFromGitHub
              IOKit
              lm_sensors
              ncurses
              systemd
              ;
          };
        };
      };
    };
}
