# Module to provide an interface for integrating derivation builder functions
#   like for example, mkDerivation, buildPythonPackage, etc...

{config, lib, ...}: let
  l = lib // builtins;
  t = l.types;
in {
  options = {

    final.outputs = l.mkOption {
      type = t.listOf t.str;
      description = "Outputs of the derivation this package function produces";
    };

    final.package-args = l.mkOption {
      type = t.anything;
      description = "The arguments which will be passed to `final.package-func`";
    };

    final.package-func = l.mkOption {
      type = t.raw;
      description = "Will be called with `final.package-args` in order to derive `final.package-func-result`";
    };

    final.package-func-result = l.mkOption {
      type = t.raw;
      description = ''
        The result of calling the final derivation function.
        This is not necessarily the same as `final.package`. The function output might not be compatible to the interface of `final.package` and additional logic might be needed to create `final.package`.
      '';
      default = config.final.package-func config.final.package-args;
      readOnly = true;
    };
  };
}
