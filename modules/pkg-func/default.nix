# Module to provide an interface for integrating derivation builder functions
#   like for example, mkDerivation, buildPythonPackage, etc...

{config, lib, ...}: let
  l = lib // builtins;
  t = l.types;
in {
  options = {

    final.derivation-args = l.mkOption {
      type = t.raw;
      description = "The arguments which will be passed to `final.derivation-func`";
    };

    final.derivation-func = l.mkOption {
      type = t.raw;
      description = "Will be called with `final.derivation-args` in order to derive `final.derivation-func-result`";
    };

    final.derivation-func-result = l.mkOption {
      type = t.raw;
      description = ''
        The result of calling the final derivation function.
        This is not necessarily the same as `final.derivation`. The function output might not be compatible to the interface of `final.derivation` and additional logic might be needed to create `final.derivation`.
      '';
      default = config.final.derivation-func config.final.derivation-args;
      readOnly = true;
    };
  };
}
