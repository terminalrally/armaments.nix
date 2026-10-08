{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "titus";
  version = "1.2.10";

  src = fetchFromGitHub {
    owner = "praetorian-inc";
    repo = "titus";
    rev = "v${version}";
    hash = "sha256-D7XF4W9n61oauyNklcUG58v9u19hlqm8RwOPYqkrPTs=";
  };

  vendorHash = "sha256-1kJeOd9laPbGBQP4hDKg5t4rVy0NqUG4QZj9LupV7+c=";

  subPackages = [ "cmd/titus" ];

  # Pure-Go engine; skips the Vectorscan/Hyperscan build.
  env.CGO_ENABLED = "0";

  doCheck = false;

  meta = with lib; {
    description = "High-performance secrets scanner for source code, git history and container images";
    homepage = "https://github.com/praetorian-inc/titus";
    license = licenses.asl20;
    mainProgram = "titus";
  };
}

