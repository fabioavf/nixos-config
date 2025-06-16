# /overlays/macbook-audio.nix
# MacBook Pro audio driver overlay for Cirrus Logic CS8409 chip

final: prev: {
  snd-hda-macbookpro = final.stdenv.mkDerivation rec {
    pname = "snd-hda-macbookpro";
    version = "unstable-2024-01-01";

    src = final.fetchFromGitHub {
      owner = "davidjo";
      repo = "snd_hda_macbookpro";
      rev = "259cc39e243daef170f145ba87ad134239b5967f";  # Latest commit
      hash = "sha256-M1dE4QC7mYFGFU3n4mrkelqU/ZfCA4ycwIcYVsrA4MY=";
    };

    nativeBuildInputs = with final; [
      kmod
      gnumake
      patch
      wget
      gnutar
      gzip
      xz  # for extracting .tar.xz
    ];

    buildInputs = [ final.linuxPackages.kernel.dev ];

    hardeningDisable = [ "pic" "format" ];

    prePatch = ''
      # Copy source to writable directory
      cp -r $src/* .
      chmod -R +w .
    '';

    configurePhase = ''
      runHook preConfigure

      # FIXED: Parse kernel version with explicit logic for 6.x
      kernel_version="${final.linuxPackages.kernel.version}"
      major_version=$(echo $kernel_version | cut -d '.' -f1)
      minor_version=$(echo $kernel_version | cut -d '.' -f2)

      echo "Kernel version: $kernel_version (major: $major_version, minor: $minor_version)"

      # FIXED: Explicit kernel version logic
      if [ $major_version -ge 6 ]; then
        echo "Using CS8409 driver for kernel 6.x+"
        export USE_CIRRUS=0
        export MODULE_NAME="snd-hda-codec-cs8409"
      elif [ $major_version -eq 5 ] && [ $minor_version -ge 13 ]; then
        echo "Using CS8409 driver for kernel >= 5.13"
        export USE_CIRRUS=0
        export MODULE_NAME="snd-hda-codec-cs8409"
      else
        echo "Using CIRRUS driver for kernel < 5.13"
        export USE_CIRRUS=1
        export MODULE_NAME="snd-hda-codec-cirrus"
      fi

      echo "Selected: $MODULE_NAME (USE_CIRRUS=$USE_CIRRUS)"

      # Create build directory and setup HDA sources
      mkdir -p build/hda

      # Extract and copy HDA sources from kernel source package
      echo "Extracting kernel source..."
      mkdir -p kernel-source
      tar -xf "${final.linuxPackages.kernel.src}" -C kernel-source --strip-components=1

      if [ -d "kernel-source/sound/pci/hda" ]; then
        echo "Found HDA sources in extracted kernel source"
        cp -r kernel-source/sound/pci/hda/* build/hda/
      else
        echo "ERROR: Could not find kernel HDA sources in extracted source"
        echo "Available directories in kernel source:"
        find kernel-source -name "*hda*" -type d | head -10
        exit 1
      fi

      # Verify we have HDA source files
      if [ ! -f "build/hda/patch_realtek.c" ]; then
        echo "ERROR: Could not find expected HDA source files"
        echo "Files in build/hda:"
        ls -la build/hda/ | head -20
        exit 1
      fi

      echo "Successfully extracted HDA sources, proceeding with patches..."

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      cd build/hda

      # Backup original Makefile and install our custom one
      mv Makefile Makefile.orig
      cp ../../patch_cirrus/Makefile .
      cp ../../patch_cirrus/patch_cirrus_* .

      # FIXED: Apply patches and create correct Makefile
      if [ "$USE_CIRRUS" = "1" ]; then
        echo "Applying CIRRUS patches for kernel < 5.13"
        patch -b -p2 < ../../patch_patch_cirrus.c.diff

        # Create Makefile for CIRRUS build
        cat > Makefile << 'EOF'
snd-hda-codec-cirrus-objs := patch_cirrus.o
obj-m += snd-hda-codec-cirrus.o

ccflags-y += -I$(srctree)/sound/pci/hda
ccflags-y += -DAPPLE_PINSENSE_FIXUP -DAPPLE_CODECS -DCONFIG_SND_HDA_RECONFIG=1
ccflags-y += -Wno-unused-variable -Wno-unused-function -Wno-empty-body
EOF
      else
        echo "Applying CS8409 patches for kernel >= 5.13"
        patch -b -p2 < ../../patch_patch_cs8409.c.diff

        # Apply header patches (using mainline versions since we're on NixOS)
        kernel_version="${final.linuxPackages.kernel.version}"
        major_version=$(echo $kernel_version | cut -d '.' -f1)
        minor_version=$(echo $kernel_version | cut -d '.' -f2)

        if [ $major_version -gt 5 ] || ([ $major_version -eq 5 ] && [ $minor_version -ge 19 ]); then
          echo "Applying current CS8409 header patches"
          patch -b -p2 < ../../patch_patch_cs8409.h.diff
          patch -b -p2 < ../../patch_patch_cirrus_apple.h.diff
        else
          echo "Applying legacy CS8409 header patches"
          patch -b -p2 < ../../patches/patch_patch_cs8409.h.main.pre519.diff
        fi

        # Create Makefile for CS8409 build
        cat > Makefile << 'EOF'
snd-hda-codec-cs8409-objs := patch_cs8409.o patch_cs8409-tables.o
obj-m += snd-hda-codec-cs8409.o

ccflags-y += -I$(srctree)/sound/pci/hda
ccflags-y += -DAPPLE_PINSENSE_FIXUP -DAPPLE_CODECS -DCONFIG_SND_HDA_RECONFIG=1
ccflags-y += -Wno-unused-variable -Wno-unused-function -Wno-empty-body

# Create empty tables file if it doesn't exist
$(shell [ ! -f patch_cs8409-tables.c ] && echo '// SPDX-License-Identifier: GPL-2.0-or-later' > patch_cs8409-tables.c)
EOF
      fi

      cd ../..

      # Build the module using the kernel build system
      echo "Building kernel module..."
      export KERNEL_BUILD="${final.linuxPackages.kernel.dev}/lib/modules/${final.linuxPackages.kernel.modDirVersion}/build"
      export KERNELRELEASE="${final.linuxPackages.kernel.modDirVersion}"

      # Build directly using the kernel build system (no Makefile override needed)
      cd build/hda
      make -C "$KERNEL_BUILD" M="$PWD" modules
      cd ../..

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      # FIXED: Install to updates/ for higher priority than built-in modules
      mkdir -p "$out/lib/modules/${final.linuxPackages.kernel.modDirVersion}/updates"

      # Install the built module based on what was selected
      if [ "$USE_CIRRUS" = "1" ]; then
        if [ -f "build/hda/snd-hda-codec-cirrus.ko" ]; then
          echo "Installing snd-hda-codec-cirrus.ko to updates/"
          cp build/hda/snd-hda-codec-cirrus.ko "$out/lib/modules/${final.linuxPackages.kernel.modDirVersion}/updates/"
        else
          echo "ERROR: CIRRUS module not built"
          ls -la build/hda/*.ko || echo "No .ko files found"
          exit 1
        fi
      else
        if [ -f "build/hda/snd-hda-codec-cs8409.ko" ]; then
          echo "Installing snd-hda-codec-cs8409.ko to updates/"
          cp build/hda/snd-hda-codec-cs8409.ko "$out/lib/modules/${final.linuxPackages.kernel.modDirVersion}/updates/"
        else
          echo "ERROR: CS8409 module not built"
          ls -la build/hda/*.ko || echo "No .ko files found"
          exit 1
        fi
      fi

      # Verify the module was built correctly
      echo "Installed modules:"
      ls -la "$out/lib/modules/${final.linuxPackages.kernel.modDirVersion}/updates/"

      runHook postInstall
    '';

    meta = with final.lib; {
      description = "MacBook Pro audio driver for Cirrus Logic 8409 HDA";
      homepage = "https://github.com/davidjo/snd_hda_macbookpro";
      license = licenses.gpl2Only;
      platforms = platforms.linux;
      maintainers = [ ];
      broken = false;
    };
  };
}