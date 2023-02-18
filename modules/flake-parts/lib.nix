{ self, lib, ... }: {
  flake.lib = import (self + /lib.nix) {inherit lib;};
}
