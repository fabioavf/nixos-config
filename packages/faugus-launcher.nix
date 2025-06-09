{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, python3
, python3Packages
, gobject-introspection
, gtk3
, glib
, imagemagick
, icoextract
, libayatana-appindicator
, wrapGAppsHook
}:

python3Packages.buildPythonApplication rec {
  pname = "faugus-launcher";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "Faugus";
    repo = "faugus-launcher";
    rev = "${version}";
    hash = "sha256-J7s1WoNgp4hWuNR28e6yG3ZijLrjlEeLJ8RtKeS+jcY=";
  };

  format = "other";

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    wrapGAppsHook
  ];

  buildInputs = [
    gtk3
    glib
    libayatana-appindicator
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    requests
    pillow
    filelock
    vdf
    psutil
  ];

  postPatch = ''
    # Fix shebang in main script
    substituteInPlace faugus_launcher.py \
      --replace "#!/usr/bin/env python3" "#!${python3}/bin/python3"
    
    # Ensure imagemagick and icoextract are available
    substituteInPlace faugus_components.py \
      --replace "convert" "${imagemagick}/bin/convert" \
      --replace "icoextract" "${icoextract}/bin/icoextract"
  '';

  configurePhase = ''
    runHook preConfigure
    meson setup builddir --prefix=$out
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    cd builddir
    ninja
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    ninja install
    runHook postInstall
  '';

  # Don't strip Python bytecode
  dontStrip = true;

  meta = with lib; {
    description = "A game launcher for managing and running Windows games on Linux";
    homepage = "https://github.com/Faugus/faugus-launcher";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "faugus-launcher";
  };
}