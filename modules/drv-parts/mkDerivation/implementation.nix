{
  config,
  lib,
  ...
}: let
  l = lib // builtins;
  t = l.types;

  name =
    if config.pname != null
    then "${config.pname}-${config.version}"
    else if config.name != null
    then config.name
    else if config.final.package-func-result ? name
    then config.final.package-func-result.name
    else throw "Cannot determine package name";

  derivation =
    {
      inherit name;
    }
    # meta
    // (l.optionalAttrs (config.passthru ? meta) {
      inherit (config.passthru) meta;
    })
    # tests
    // (l.optionalAttrs (config.passthru ? tests) {
      inherit (config.passthru) tests;
    });

in {
  imports = [
    ../derivation-common/implementation.nix
    ../pkg-func/implementation.nix
  ];
  config.final.package-func = lib.mkDefault config.deps.stdenv.mkDerivation;

  # add mkDerivation specific derivation attributes
  config.final.package = derivation;
}
