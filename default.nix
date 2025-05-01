let
  pkgs = import <nixpkgs> { };
  inherit (pkgs) lib;
in
lib.fix (self: {
  package = pkgs.callPackage ./package.nix { };
  streamImage = pkgs.dockerTools.streamLayeredImage (
    let
      port = "8080";
    in
    {
      name = "next-test";
      contents = [
        self.package
      ];
      config = {
        Cmd = [
          "/bin/next-test"
        ];
        Env = [
          "PORT=${port}"
          "HOSTNAME=::"
          "NODE_ENV=production"
          "NEXT_TELEMETRY_DISABLED=1"
        ];
        ExposedPorts = {
          "${port}/tcp" = { };
        };
      };

    }
  );
})
