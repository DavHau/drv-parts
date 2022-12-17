{config, lib, drv-backends, ...}: let
  deps = config.deps;
in {

  # select mkDerivation as a backend for this package
  imports = [drv-backends.mkDerivation];

  options = {
    sensorsSupport = lib.mkOption {
      type = lib.types.bool;
      default = config.stdenv.isLinux;
    };
    systemdSupport = lib.mkOption {
      type = lib.types.bool;
      default = config.stdenv.isLinux;
    };
  };

  config = {
    # set options
    pname = "htop";
    version = "3.2.1";

    deps = {pkgs, ...}: {
      inherit (pkgs)
        autoreconfHook
        fetchFromGitHub
        IOKit
        lm_sensors
        ncurses
        systemd
        ;
    };

    src = deps.fetchFromGitHub {
      owner = "htop-dev";
      repo = config.pname;
      rev = config.version;
      sha256 = "sha256-MwtsvdPHcUdegsYj9NGyded5XJQxXri1IM1j4gef1Xk=";
    };

    nativeBuildInputs = [ deps.autoreconfHook ];

    buildInputs = [ deps.ncurses ]
      ++ lib.optional config.stdenv.isDarwin deps.IOKit
      ++ lib.optional config.sensorsSupport deps.lm_sensors
      ++ lib.optional config.systemdSupport deps.systemd
    ;

    configureFlags = [ "--enable-unicode" "--sysconfdir=/etc" ]
      ++ lib.optional config.sensorsSupport "--with-sensors"
    ;

    postFixup =
      let
        optionalPatch = pred: so: lib.optionalString pred "patchelf --add-needed ${so} $out/bin/htop";
      in
      ''
        ${optionalPatch config.sensorsSupport "${deps.lm_sensors}/lib/libsensors.so"}
        ${optionalPatch config.systemdSupport "${deps.systemd}/lib/libsystemd.so"}
      '';

    meta = with lib; {
      description = "An interactive process viewer";
      homepage = "https://htop.dev";
      license = licenses.gpl2Only;
      platforms = platforms.all;
      maintainers = with maintainers; [ rob relrod SuperSandro2000 ];
      changelog = "https://github.com/htop-dev/htop/blob/${version}/ChangeLog";
    };
  };
}
