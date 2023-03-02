# drv-parts

This is experimental, use with care!

`drv-parts` replaces `callPackage`, `override`, `overrideAttrs`, `...` as a mechanism for configuring packages.
It makes package configuration feel similar to NixOS system configuration.

This is an implementation of ideas first drafted at [DavHau/pkgs-modules](https://github.com/DavHau/pkgs-modules).

It is recommended to use `drv-parts` through [flake-parts](https://flake.parts) (see [examples/flake-parts](/examples/flake-parts)).

There is also support for flake-less usage (see [examples/no-flake](/examples/no-flake)).

# Funding by NLNet

drv-parts was funded as part of the [dream2nix](https://github.com/nix-community/dream2nix) project through the [NGI Assure](https://nlnet.nl/assure) Fund, a fund established by [NLnet](https://nlnet.nl/) with financial support from the European Commission's [Next Generation Internet](https://ngi.eu/) programme, under the aegis of DG Communications Networks, Content and Technology under grant agreement No 957073. **Applications are still open, you can [apply today](https://nlnet.nl/propose)**.

# Why Modules?

Declaring derivations as modules solves a number of issues.
For more details on the problems, visit [DavHau/pkgs-modules](https://github.com/DavHau/pkgs-modules).
Also I recommend watching @edolstra 's [talk about this topic](https://www.youtube.com/watch?v=dTd499Y31ig).

# Benefits

## No more override functions

Changing options of packages in nixpkgs can require chaining different override functions like this:

```nix
{
  htop-mod = let
    htop-overridden = pkgs.htop.overrideAttrs (old: {
      pname = "htop-mod";
    });
  in
    htop-overridden.override (old: {
      sensorsSupport = false;
    });
}
```

... while doing the same using `drv-parts` looks like this:

```nix
{
  htop-mod = {
    imports = [./htop.nix];
    public.name = lib.mkForce "htop-mod";
    flags.sensorsSupport = false;
  };
}
```

See htop module definition [here](/examples/flake-parts/htop/htop.nix).

## Type safety

The following code in nixpkgs mkDerivation mysteriously skips the patches:

```nix
mkDerivation {
  # ...
  dontPatch = "false";
}
```

... while doing the same using `drv-parts` raises an informative type error:

```
A definition for option `[...].dontPatch' is not of type `boolean' [...]
```

## Catch typos

The following code in nixpkgs mkDerivation builds **without** openssl_3.

```nix
mkDerivation {
  # ...
  nativBuildInputs = [openssl_3];
}
```

... while doing the same using `drv-parts` raises an informative error:

```
The option `[...].nativBuildInputs' does not exist
```

## Environment variables clearly defined

`drv-parts` requires a clear distinction between known parameters and user-defined variables.
Defining `SOME_VARIABLE` at the top-level, would raise:

```
The option `[...].SOME_VARIABLE' does not exist
```

Instead it has to be defined under `env.`:

```nix
{
  my-package = {
    # ...
    env.SOME_VARIABLE = "example";
  };
}
```

## Package options documentation

Documentation similar to [search.nixos.org](https://search.nixos.org) can be generated for packages declared via `drv-parts`.

This is not yet implemented.

## Package blueprints

With `drv-parts`, packages don't need to be fully declared. Options can be left without defaults, requiring the consumer to complete the definition.

For example, this can be useful for lang2nix tools, where `src` and `version` are dynamically provided by a lock file parser.

## Freedom of abstraction

The nixos module system gives maintainers more freedom over how packages are split into modules. Separation of concerns can be implemented more easily.
For example, the dependency tree of a package set can be factored out into a separate module, allowing for simpler modification.
