{ pkgs, lib, ... }:

let
  # Recursively list all ttf files under the assets directory
  assetDir = ./assets;
  allFiles = lib.fileset.toList (assetDir);
  ttfFiles = lib.filter (file:
    lib.hasSuffix ".ttf" (builtins.baseNameOf file)
  ) allFiles;

  # Generate package name from file path
  makeName = file:
    let
      # Remove the assetDir prefix and replace '/' with '-'
      rel = lib.removePrefix (builtins.toString assetDir + "/") (builtins.toString file);
      withDash = lib.replaceStrings ["/" " "] ["-" "-"] rel;
      name = lib.removeSuffix ".ttf" withDash;
    in name;

  mkFontPkg = file: let
    pkgName = makeName file;
    fontPath = file;
  in pkgs.stdenvNoCC.mkDerivation {
    pname = "mmbn-font-${pkgName}";
    version = "1.0";
    src = fontPath;
    dontUnpack = true;
    installPhase = ''
      runHook preInstall
      
      install -Dm644 ${fontPath} $out/share/fonts/truetype/${pkgName}

      runHook postInstall
    '';
  };

  fontPkgs = lib.genAttrs (
    lib.map makeName ttfFiles
  ) (name: let
    f = lib.head ( lib.filter ( file: makeName file == name ) ttfFiles );
    in mkFontPkg f
  );
in
fontPkgs
