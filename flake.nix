{
  description = "";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      systems = [
        # "aarch64-darwin"
        # "aarch64-linux"
        # "x86_64-darwin"
        "x86_64-linux"
      ];

      imports = [
        ./modules/flake-parts/all-modules.nix
      ];

      flake.flakeModule = ./modules/flake-parts/drv-parts.nix;
    };
}
