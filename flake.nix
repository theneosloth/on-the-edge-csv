{
  inputs = { utils.url = "github:numtide/flake-utils"; };
  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        libs = [ pkgs.openssl];
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs;
            [
              (sbcl.withPackages (ps:
                with ps; [
                  sbclPackages.alexandria
                  sbclPackages.transducers
                  sbclPackages.arrow-macros
                  sbclPackages.parseq
                  sbclPackages.serapeum
                  sbclPackages.sqlite
                  sbclPackages.jzon
                  sbclPackages.cl-csv
                ]))
            ];
        };
      });
}
