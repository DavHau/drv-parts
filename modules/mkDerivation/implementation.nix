{
  config,
  lib,
  ...
}: let
  l = lib // builtins;
  t = l.types;
  package =
    # meta
    (l.optionalAttrs (config.passthru ? meta) {
      inherit (config.passthru) meta;
    })
    # tests
    // (l.optionalAttrs (config.passthru ? tests) {
      inherit (config.passthru) tests;
    });
in {
  imports = [
    ../derivation-common/implementation.nix
  ];
  config.final.derivation-func = lib.mkDefault config.stdenv.mkDerivation;

  # add mkDerivation specific derivation attributes
  config.final.derivation = package;
}
