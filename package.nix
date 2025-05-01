{
  stdenv,
  lib,
  nodejs,
  yarnConfigHook,
  yarnBuildHook,
  makeBinaryWrapper,
  fetchYarnDeps,
  basePath ? "/next-test",
}:
let
  package-json = builtins.fromJSON (builtins.readFile ./package.json);
in
stdenv.mkDerivation (final: {
  pname = package-json.name;
  version = package-json.version;
  src = lib.cleanSource ./.;

  nativeBuildInputs = [
    nodejs
    yarnConfigHook
    yarnBuildHook
    makeBinaryWrapper
  ];

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = final.src + "/yarn.lock";
    hash =
      {
        "6aaebf40e46966c93a9304426b71c7cba78f9b9b" = "sha256-9LoXrxXdA5cuft5L0q/ffKMEmlBDwGKAR13Gms45Ep8=";
      }
      .${builtins.hashFile "sha1" ./yarn.lock};
  };

  preBuild = ''
    export NEXT_PUBLIC_BASE_PATH="${basePath}"
  '';

  installPhase = ''
    out2=$out/opt/${final.pname}
    mkdir -p $out/opt
    cp -r .next/standalone $out2

    cp -r public $out2
    cp -r .next/static $out2/.next

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/${final.pname} \
      --add-flags $out2/server.js \
      --set NEXT_PUBLIC_BASE_PATH "$NEXT_PUBLIC_BASE_PATH"
  '';

  meta.mainProgram = final.pname;
})
