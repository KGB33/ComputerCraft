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
      in rec
      {
        # checks = {};
        # packages = {};
        # apps.default = flake-utils.lib.mkApp {
        #   drv = self.packages.default;
        # };
        devShells = {
          default = pkgs.mkShell {
            # checks = self.checks.${system};
            packages = with pkgs; [
              lua52Packages.readline
              fennel
            ];
          };
        };
      }
    );
}
