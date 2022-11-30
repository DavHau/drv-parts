{config, inputs', lib, pkgs, ...}: let
  stdenv = pkgs.stdenv;
in {

  # select mkDerivation as a backend for this package
  imports = builtins.trace inputs'.drv-parts [inputs'.drv-parts.modules.mkDerivation];

  options = {
    sensorsSupport = lib.mkOption {
      type = lib.types.bool;
      default = stdenv.isLinux;
    };
    systemdSupport = lib.mkOption {
      type = lib.types.bool;
      default = stdenv.isLinux;
    };
  };

  config = {
    # set options
    pname = "htop";
    version = "3.2.1";

    src = pkgs.fetchFromGitHub {
      owner = "htop-dev";
      repo = config.pname;
      rev = config.version;
      sha256 = "sha256-MwtsvdPHcUdegsYj9NGyded5XJQxXri1IM1j4gef1Xk=";
    };

    nativeBuildInputs = [ pkgs.autoreconfHook ];

    buildInputs = [ pkgs.ncurses ]
      ++ lib.optional stdenv.isDarwin pkgs.IOKit
      ++ lib.optional config.sensorsSupport pkgs.lm_sensors
      ++ lib.optional config.systemdSupport pkgs.systemd
    ;

    configureFlags = [ "--enable-unicode" "--sysconfdir=/etc" ]
      ++ lib.optional config.sensorsSupport "--with-sensors"
    ;

    postFixup =
      let
        optionalPatch = pred: so: lib.optionalString pred "patchelf --add-needed ${so} $out/bin/htop";
      in
      ''
        ${optionalPatch config.sensorsSupport "${pkgs.lm_sensors}/lib/libsensors.so"}
        ${optionalPatch config.systemdSupport "${pkgs.systemd}/lib/libsystemd.so"}
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
