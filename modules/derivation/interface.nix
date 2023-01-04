{config, lib, ...}: let
  l = lib // builtins;
  t = l.types;
in rec {
  imports = [
    ../derivation-common/interface.nix
  ];

  # signal that all options should be passed to the final derivation function
  config.argsForward = l.mapAttrs (_: _: true) options;

  options = {
    # basic arguments
    builder = lib.mkOption {
      type = t.oneOf [t.str t.path t.package];
    };
    name = lib.mkOption {
      type = t.str;
    };
    system = lib.mkOption {
      type = t.str;
    };
    __contentAddressed = lib.mkOption {
      type = t.bool;
      default = false;
    };
    passAsFile = lib.mkOption {
      description = lib.mdDoc ''
        List of derivation fields to be passed as files rather than
        environment variables.
        
        Fields marked using `passAsFile` will instead cause shell
        variables, `<NAME>Path` to be created with a path to a temporary
        file containing the stringized contents of the field.
        
        This is useful for values with string representations which
        are longer than certain shells' max value length
        ( ~1024 characters is a sane limit for context ).
      '';
      type = t.listOf t.str;
      default = [];
      example = lib.literalExpression ''
        derivation {
          name       = "passAsFile-example";
          passAsFile = ["foo"];
          foo        = "bar";
          builder    = "/bin/sh";
          # Here we refer to `$fooPath', not `$foo'.
          args   = ["-c" "echo \"$fooPath\" > \"$out\";"];
          system = builtins.currentSystem;
        };
      '';
    };
    outputHash = lib.mkOption {
      description = lib.mdDoc ''
        A string containing the hash in either hexadecimal or
        base-32 notation.
        Setting this option causes Nix to create a "fixed output
        derivation" as opposed to an "input addressed derivation",
        purifying otherwise impure operations in builders.
        
        If this field is non-null `outputHashAlgo` and
        `outputHashMode` options should also be set accordingly.
      '';
      type = t.nullOr t.str;
      default = null;
      example = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
    outputHashAlgo = lib.mkOption {
      description = lib.mdDoc ''
        The hash algorithm used to compute `outputHash`.
      '';
      type = t.enum ["sha1" "sha256" "sha512"];
      default = "sha256";
    };
    outputHashMode = lib.mkOption {
      description = lib.mdDoc ''
        Determines how `outputHash` is computed - either by performing
        a checksum on the contents of a single non-executable file for
        `flat` mode, or by computing the `narHash` of a directory or
        executable file for `recursive`.
      '';
      type = t.enum ["flat" "recursive"];
      default = "recursive";
    };
    preferLocalBuild = lib.mkOption {
      description = ''
        If this attribute is set to true and distributed building is
        enabled, then, if possible, the derivation will be built locally
        instead of forwarded to a remote machine.
        This is appropriate for trivial builders where the cost of doing
        a download or remote build would exceed the cost of building locally.
      '';
      type = t.bool;
      default = false;
    };
    allowSubstitutes = lib.mkOption {
      description = lib.mdDoc ''
        If this attribute is set to `false`, then Nix will always build this
        derivation; it will not try to substitute its outputs.
        This is useful for very trivial derivations (such as `writeText` in
        Nixpkgs) that are cheaper to build than to substitute from a
        binary cache.
        
        Note
        You need to have a builder configured which satisfies the derivation's
        system attribute, since the derivation cannot be substituted.
        Thus it is usually a good idea to align system with
        `builtins.currentSystem` when setting `allowSubstitutes` to `false`.
        For most trivial derivations this should be the case.
      '';
      type = t.bool;
      default = true;
      example = lib.literalExpression ''
        { system }:
        derivation {
          inherit system;
          allowSubstitutes =
            ( builtins.currentSystem or "unknown" ) != system;
          # ...
        };
      '';
    };
  };
}
