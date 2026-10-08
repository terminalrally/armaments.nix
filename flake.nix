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
        unstable = import nixpkgs-unstable { inherit system; };

        # Go tools routinely require the newest toolchain; take it from unstable.
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (final: prev: { inherit (unstable) buildGoModule; }) ];
        };

        packageDir = builtins.attrNames (builtins.readDir ./derivations);

        packages = builtins.listToAttrs (map (name: {
          inherit name;
          value = pkgs.callPackage (./derivations + "/${name}") { };
        }) packageDir);
      in { packages = packages // {
        default = packages.LokiWallpaper;
      }; });

}
