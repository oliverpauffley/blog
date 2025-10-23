{
  description = "hugo blog";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    hugo-coder = {
      url = "github:luizdepra/hugo-coder";
      flake = false;
    };
  };

  outputs = { nixpkgs, flake-utils, hugo-coder, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive)
            scheme-full latex-bin luatex xetex beamer beamerdarkthemes pgfopts
            fira xkeyval fontaxes fancyvrb booktabs caption # table
            xecjk ctex unicode-math;
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ git nixpkgs-fmt hugo tex inkscape ];
        };
        packages = rec {
          hugo-website =
            pkgs.callPackage ./derivation.nix { hugo-coder = hugo-coder; };
          default = hugo-website;
        };
      });
}
