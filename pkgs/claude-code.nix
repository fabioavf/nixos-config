# /etc/nixos/pkgs/claude-code.nix
# Claude Code - AI coding assistant CLI

{ lib
, stdenv
, fetchurl
, makeWrapper
, nodejs
}:

stdenv.mkDerivation rec {
  pname = "claude-code";
  version = "1.0.65";

  src = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
    sha256 = "JhrXHqYCMdjPSZprB9t9cbiCaLL/1YsdAHPqV86D9r0=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ nodejs ];

  unpackPhase = ''
    tar -xzf $src
    cd package
  '';

  installPhase = ''
    runHook preInstall

    # Create the output directory structure
    mkdir -p $out/lib/node_modules/@anthropic-ai/claude-code
    mkdir -p $out/bin

    # Copy the package contents
    cp -r . $out/lib/node_modules/@anthropic-ai/claude-code/

    # Create the executable wrapper (using correct file and binary name)
    makeWrapper ${nodejs}/bin/node $out/bin/claude \
      --add-flags "$out/lib/node_modules/@anthropic-ai/claude-code/cli.js"

    # Also create claude-code symlink for consistency
    ln -s $out/bin/claude $out/bin/claude-code

    runHook postInstall
  '';

  meta = with lib; {
    description = "Claude Code - AI coding assistant CLI";
    homepage = "https://claude.ai";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.unix;
    mainProgram = "claude-code";
  };
}
