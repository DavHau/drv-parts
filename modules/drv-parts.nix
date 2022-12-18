{lib, flake-parts-lib, inputs, ... }:
let
  l = lib // builtins;
  t = l.types;
in {
  options.perSystem =
    flake-parts-lib.mkPerSystemOption ({config, pkgs, inputs', self', ...}: {
      options = {

        drvs = l.mkOption {
          type = t.lazyAttrsOf (
            t.submoduleWith {
              modules = [./derivation-common];
              specialArgs = {
                inherit (inputs.drv-parts) drv-backends;
                inherit (config) dependencySets;
              };
            }
          );
          description = "An attribute set of derivations";
          example = lib.literalExpression ''
            hello-simple = {

              # select mkDerivation as a backend for this package
              imports = [drv-parts.modules.mkDerivation];

              # set options
              name = "hello";
              src = builtins.fetchurl {
                url = "mirror://gnu/hello/hello-2.12.1.tar.gz";-
                sha256 = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
              };
            };

            hello-advanced = {config, ...} let
              deps = config.deps;
            in {

              # select mkDerivation as a backend for this package
              imports = [drv-parts.modules.mkDerivation];

              # Define dependencies from the "outer world" only via `deps`.
              # This allows for easy overriding later.
              deps = {pkgs, ...} {
                inherit (pkgs)
                  fetchurl
                  python
                  ;
              };

              # set options
              name = "hello";
              src = deps.fetchurl {
                url = "mirror://gnu/hello/hello-2.12.1.tar.gz";
                sha256 = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
              };

              nativeBuildInputs = [
                deps.python
              ]

              postInstall = ''''
                python -c "print('example')" > $out/example
              '''';
            };
          '';
        };

        dependencySets = l.mkOption {
          type = t.lazyAttrsOf t.raw;
          default = {
            inherit pkgs inputs';
            inherit (self') packages;
          };
          description = ''
            Define the package sets which can be used to pick dependencies from.
            Basically this specifies the arguments passed to the function defined via drvs.<name>.deps.
          '';
          example = lib.literalExpression ''
            {
              inherit pkgs inputs';
            }
          '';
        };
      };
    });

  config.perSystem = {config, pkgs, ...}: {
    /*
      TODO: I'm not sure yet if we should expose just the evaled module instead.
      The evaled module is also a valid derivation because we set
        `type = "derivation"` and `drvPath`, but it is currently missing
        attributes like `overrideAttrs` or `out`, etc.
    */
    # config.packages = config.pkgs;

    /*
      This exposes the `.derivation` attribute (the actual derivation) of each
        defined `pkgs.xxx` under the flake output `packages`.
    */
    config.packages = l.mapAttrs (name: pkg: pkg.final.derivation) config.drvs;
  };

}
