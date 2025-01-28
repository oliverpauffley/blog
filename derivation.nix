{ stdenv, hugo, hugo-coder }:
stdenv.mkDerivation {
  name = "hugo-blog";

  src = ./.;

  nativeBuildInputs = [ hugo ];
  buildPhase = ''
    cp -r $src/* .
    mkdir -p ./themes/PaperMod
    cp -r ${hugo-coder} ./themes/HugoCoder/
    ${hugo}/bin/hugo
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r public/* $out/
    runHook postInstall
  '';
}
