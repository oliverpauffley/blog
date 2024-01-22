{
  description = "A flake for developing and building my personal website";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.after-dark = {
    url = "github:getzola/after-dark";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, after-dark }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        themeName = ((builtins.fromTOML
          (builtins.readFile "${after-dark}/theme.toml")).name);
      in {
        packages.website = pkgs.stdenv.mkDerivation rec {
          pname = "static-website";
          version = "2023-01-12";
          src = ./.;
          nativeBuildInputs = [ pkgs.zola ];
          buildPhase = ''
            cd blog
            zola build --force -o ../docs
            cd ..
          '';
          installPhase = ''
            cp -r docs/ $out
            rm -rf docs/themes/*
            mkdir -p "docs/themes/${themeName}"
            cp -r --force ${after-dark}/* docs/themes/${themeName}
          '';
        };
        defaultPackage = self.packages.${system}.website;
        devShell = pkgs.mkShell {
          packages = [ pkgs.zola ];
          shellHook = ''
            mkdir -p blog/themes
            ln --force -sn "${after-dark}" "blog/themes/${themeName}"
          '';
        };
      });
}
