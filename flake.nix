{
  description = "hugo blog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    hugo-coder = {
      url = "github:luizdepra/hugo-coder";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, hugo-coder }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.git pkgs.nixpkgs-fmt pkgs.hugo ];
        };
        packages = rec {
          hugo-website =
            pkgs.callPackage ./derivation.nix { hugo-coder = hugo-coder; };
          default = hugo-website;
        };
      });
}
