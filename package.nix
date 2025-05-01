{
  stdenv,
  lib,
  nodejs,
  pnpm,
  makeBinaryWrapper,
  basePath ? "/next-test",
}:
let
  fs = lib.fileset;
  package-json = builtins.fromJSON (builtins.readFile ./package.json);
in
stdenv.mkDerivation (final: {
  pname = package-json.name;
  version = package-json.version;
  src = lib.cleanSource ./.;

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
    makeBinaryWrapper
  ];

  pnpmDeps = pnpm.fetchDeps {
    inherit (final) pname src;
    hash =
      {
        "5b001fee08f642a93c96b936e373d12fe30e11d2" = "sha256-JfnRZ2LHuidPXBJICyfnFRGCw+8HxiJ/ribp7l5DUDg=";
      }
      .${builtins.hashFile "sha1" ./pnpm-lock.yaml};
  };

  buildPhase = ''
    export NEXT_PUBLIC_BASE_PATH="${basePath}"
    pnpm build
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
