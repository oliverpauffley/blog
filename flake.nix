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
            zola build --force
          '';
          installPhase = ''
            mkdir -p "themes/${themeName}"
            cp -r --force ${after-dark}/* themes/${themeName}
          '';
        };
        defaultPackage = self.packages.${system}.website;
        devShell = pkgs.mkShell {
          packages = [ pkgs.zola ];
          shellHook = ''
            mkdir -p themes
            ln --force -sn "${after-dark}" "themes/${themeName}"
          '';
        };
      });
}
