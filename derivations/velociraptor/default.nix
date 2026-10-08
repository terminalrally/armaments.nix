{ lib
, buildGoModule
, buildNpmPackage
, fetchFromGitHub
, makeWrapper
}:

let
  pname = "velociraptor";
  version = "0.77.3";

  src = fetchFromGitHub {
    repo = "velociraptor";
    owner = "Velocidex";
    rev = "refs/tags/v${version}";
    hash = "sha256-L1OFEgs5QWdu6vh3bDulH+C8wkwR2vBkVQ7l4ojX1T0=";
  };

  gui = buildNpmPackage {
    inherit pname version;
    src = "${src}/gui/velociraptor";
    npmDepsHash = "sha256-BM9MBe8F/mfT4JAjZcok/OpajbrGox2EPh95VjfKcPg=";

    buildPhase = ''
      runHook preBuild
        npm install
        make build
      runHook postBuild
    '';
    installPhase = ''
    runHook preInstall
      mkdir $out
      mv build $out
    runHook postInstall
    '';
  };
in

buildGoModule rec {
  inherit src pname version gui;

  vendorHash = "sha256-K6k5PRkUSFeaBgZRylawiEDOssuo3vORQ3xm58jT8XI=";

  preBuild = ''
    cp -r ${gui}/build gui/velociraptor
    chmod -R u+w gui/velociraptor/build

    # Mirrors magefile.go ensure_assets: patch the vite index, then generate ab0x.go files.
    substituteInPlace gui/velociraptor/build/index.html \
      --replace-fail '="/app/assets/index' '="{{.BasePath}}/app/assets/index'

    mkdir -p tools/genassets
    cat > tools/genassets/main.go <<'EOF'
    package main

    import (
      "log"

      "github.com/Velocidex/fileb0x/runner"
    )

    func main() {
      for _, a := range []string{
        "artifacts/b0x.yaml",
        "config/b0x.yaml",
        "gui/velociraptor/b0x.yaml",
        "crypto/b0x.yaml",
      } {
        if err := runner.Process(a); err != nil {
          log.Fatal(err)
        }
      }
    }
    EOF
    go run ./tools/genassets
    rm -r tools/genassets
  '';

  subPackages = [ "bin" ];

  doCheck = false;

  tags = [ "server_vql" "extras" "disable_grpc_modules" ];

  postInstall = ''
    mv $out/bin/bin $out/bin/velociraptor
  '';

  nativeBuildInputs = [
    makeWrapper
  ];

  meta = with lib;{

  };
}