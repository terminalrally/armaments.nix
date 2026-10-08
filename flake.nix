{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org/" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        unstable = import nixpkgs-unstable { inherit system; };

        # Packages that need a newer toolchain than the stable channel provides.
        extraArgs = {
          Titus = { inherit (unstable) buildGoModule; };
        };

        packageDir = builtins.attrNames (builtins.readDir ./derivations);

        packages = builtins.listToAttrs (map (name: {
          inherit name;
          value = pkgs.callPackage (./derivations + "/${name}") (extraArgs.${name} or { });
        }) packageDir);
      in { packages = packages // {
        default = packages.LokiWallpaper;
      }; });

}
