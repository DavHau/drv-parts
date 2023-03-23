{
  lib,
  dependencySets,
  ...
}: let
  l = lib // builtins;
  t = l.types;

  # A stricteer submodule type that prevents derivations from being
  # detected as modules by accident. (derivations are attrs as well as modules)
  drvPart = let
    type = (t.submoduleWith{
      modules = [../modules/drv-parts/core];
      specialArgs = {inherit dependencySets;};
    });
  in
    type
    // {
      # Ensure that derivations are never detected as modules by accident.
      check = val: type.check val && (val.type or null != "derivation");
    };

  # polymorphic type, that can either represent a derivation or a drv-part.
  # The stricter`drvPart` type is needed to prevent derivations being
  #   classified as modules by accident.
  # This is important because derivations cannot be merged with drv-parts.
  drvPartOrPackage = t.either derivationType drvPart;

  derivationType = t.oneOf [t.str t.path t.package];

in {
  inherit
    drvPart
    drvPartOrPackage
    ;
}
