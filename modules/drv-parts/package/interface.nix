{config, lib, dependencySets, ...}: let
  l = lib // builtins;
  t = l.types;

  opts = let
    optsPackage = import ./optsPackage.nix {
      inherit lib;
      inherit (config) outputs;
    };
    optsPackageCompat = import ./optsPackageCompat.nix {inherit lib;};
    optsPackageDrvParts = import ./optsPackageDrvParts.nix {inherit lib;};
  in
    optsPackage // optsPackageCompat // optsPackageDrvParts;

in {

  # this will contain the resulting derivation
  options.final.package = l.mkOption {
    type = t.submodule {
      freeformType = t.lazyAttrsOf t.anything;
      options = opts;
    };
  };
}
