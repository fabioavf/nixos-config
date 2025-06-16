# /etc/nixos/pkgs/faugus-launcher.nix
# Faugus Launcher - Game launcher for managing Windows games on Linux

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
, wrapGAppsHook3
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
    wrapGAppsHook3
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
    # Fix shebangs in all Python scripts
    substituteInPlace faugus_launcher.py \
      --replace "#!/usr/bin/env python3" "#!${python3}/bin/python3"
    substituteInPlace faugus_run.py \
      --replace "#!/usr/bin/env python3" "#!${python3}/bin/python3"
    substituteInPlace faugus_proton_manager.py \
      --replace "#!/usr/bin/env python3" "#!${python3}/bin/python3"
    substituteInPlace faugus_components.py \
      --replace "#!/usr/bin/python3" "#!${python3}/bin/python3"
    
    # Replace subprocess calls to use the binary directly instead of python + script
    substituteInPlace faugus_launcher.py \
      --replace "subprocess.Popen([sys.executable, faugus_run_path, command]" \
                "subprocess.Popen([faugus_run_path, command]" \
      --replace "subprocess.Popen([sys.executable, faugus_run, command]" \
                "subprocess.Popen([faugus_run, command]" \
      --replace "subprocess.Popen([sys.executable, faugus_run_path, command, \"winetricks\"]" \
                "subprocess.Popen([faugus_run_path, command, \"winetricks\"]" \
      --replace "subprocess.run([faugus_run_path, command]" \
                "subprocess.run([faugus_run_path, command]"
    
    # Ensure binary paths are correct for Nix
    substituteInPlace faugus_components.py \
      --replace "convert" "${imagemagick}/bin/convert" \
      --replace "icoextract" "${icoextract}/bin/icoextract"
    
    # Fix umu-run path in launcher
    substituteInPlace faugus_launcher.py \
      --replace '"/usr/bin/umu-run"' '"umu-run"'
  '';

  # Let wrapGAppsHook3 handle GTK app wrapping
  dontWrapGApps = true;
  
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
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
