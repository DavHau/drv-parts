funcName:

{config, lib, drv-parts, ...}: let
  l = lib // builtins;
  t = l.types;
in {

  imports = [
    drv-parts.modules.drv-parts.mkDerivation
  ];

  options.${funcName} = lib.mkOption {
    type = t.attrsOf t.anything;
    default = {};
    description = "Arguments for ${funcName}";
  };

  options.deps.${funcName} = l.mkOption {
    type = t.functionTo t.anything;
    description = "The ${funcName} function to be called to generate the derivation";
  };

  config.package-func.args = config.${funcName};

  # set nixpkgs.buildPythonPackage as the final package function
  config.package-func.func = config.deps.${funcName};
}
