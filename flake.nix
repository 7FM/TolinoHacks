{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      # pkgs = nixpkgs.legacyPackages.${system};
      pkgs = import "${nixpkgs}" {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          zip
          unzip
          android-tools
          util-linux
          sqlite

          # Disassembler:
          gcc-arm-embedded
          # Build tools
          gcc
          cmake
          gnumake
          # APK decompiling tools
          apktool
        ];
      };
    });
}
