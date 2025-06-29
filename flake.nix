{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    flake-utils,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };

        ccPrograms = pkgs.stdenv.mkDerivation {
          name = "powah-ae2";
          src = pkgs.lib.cleanSource ./.;
          nativeBuildInputs = with pkgs; [fennel];
          buildPhase = ''
            find . -name "*.fnl" -type f | while read -r fnl_file; do
              lua_file="''${fnl_file%.fnl}.lua"
              echo "Compiling $fnl_file -> $lua_file"
              fennel --compile "$fnl_file" > "$lua_file"
            done
          '';
          installPhase = ''
            mkdir -p $out
            cp *.lua $out/ || true
          '';
        };
      in rec
      {
        packages = {
          ccPrograms = ccPrograms;
        };
        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs; [
              lua52Packages.readline
              fennel
              fnlfmt
            ];
          };
        };
      }
    );
}
