{
  description = "A flake for developing and building my personal website";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.anemone = {
    url = "github:Speyll/anemone";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, anemone }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        themeName = ((builtins.fromTOML
          (builtins.readFile "${anemone}/theme.toml")).name);
      in {
        packages.website = pkgs.stdenv.mkDerivation rec {
          pname = "static-website";
          version = "2023-01-12";
          src = ./.;
          nativeBuildInputs = [ pkgs.zola ];
          buildPhase = ''
            zola build --force
          '';
          installPhase = ''
            rm -rf themes
            mkdir -p "themes/${themeName}"
            cp -r --force ${anemone}/* themes/${themeName}
          '';
        };
        defaultPackage = self.packages.${system}.website;
        devShell = pkgs.mkShell {
          packages = [ pkgs.zola ];
          shellHook = ''
            mkdir -p themes
            ln --force -sn "${anemone}" "themes/${themeName}"
          '';
        };
      });
}
