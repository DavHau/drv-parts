{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit self;} {
      systems = ["x86_64-linux"];
      imports = [./modules/drv-parts.nix];

      perSystem = {config, pkgs, ...}: {
        pkgs.hello = {
          name = "hello";
          src = pkgs.fetchurl {
            url = "mirror://gnu/hello/hello-2.12.1.tar.gz";
            sha256 = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
          };
          passthru.yolo = "lol";
        };
      };
    };
}
