# /etc/nixos/overlays/packages.nix
# Custom package definitions

final: prev: {
  # Claude Code - AI coding assistant CLI
  claude-code = final.stdenv.mkDerivation rec {
    pname = "claude-code";
    version = "1.0.24";

    src = final.fetchurl {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
      sha256 = "VXPrvA7yM7tpZ4wAbsMtTPL5TRMkNlqp6inLPiihI7I=";
    };

    nativeBuildInputs = [ final.makeWrapper ];
    buildInputs = [ final.nodejs ];

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
      makeWrapper ${final.nodejs}/bin/node $out/bin/claude \
        --add-flags "$out/lib/node_modules/@anthropic-ai/claude-code/cli.js"

      # Also create claude-code symlink for consistency
      ln -s $out/bin/claude $out/bin/claude-code

      runHook postInstall
    '';

    meta = with final.lib; {
      description = "Claude Code - AI coding assistant CLI";
      homepage = "https://claude.ai";
      license = licenses.mit;
      maintainers = [ ];
      platforms = platforms.unix;
      mainProgram = "claude-code";
    };
  };
}
