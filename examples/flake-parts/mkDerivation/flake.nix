{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    drv-parts.url = "github:DavHau/drv-parts";
  };

  outputs = {
    self,
    flake-parts,
    drv-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      # enable the drv-parts plugin for flake-parts
      imports = [drv-parts.modules.flake-parts.drv-parts];

      perSystem = {config, pkgs, ...}: {
        checks = config.packages;
        drvs.hello = {

          # select mkDerivation as a backend for this package
          imports = [drv-parts.modules.drv-parts.mkDerivation];

          deps = {nixpkgs, ...}: {
            inherit (nixpkgs) stdenv;
          };

          # set options
          name = "hello";
          src = pkgs.fetchurl {
            url = "mirror://gnu/hello/hello-2.12.1.tar.gz";
            sha256 = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
          };
        };
      };
    };
}
