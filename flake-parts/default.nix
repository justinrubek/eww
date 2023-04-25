{
  inputs,
  self,
  ...
} @ part-inputs: {
  imports = [];

  perSystem = {
    config,
    pkgs,
    lib,
    system,
    inputs',
    self',
    ...
  }: let
    devTools = [
      # rust tooling
      self'.packages.rust-toolchain
      pkgs.cargo-audit
      pkgs.cargo-udeps
      pkgs.bacon
      # misc
    ];

    extraPackages = self'.legacyPackages.cargoExtraNativeBuildInputs ++ self'.legacyPackages.cargoExtraBuildInputs;
  in rec {
    devShells.default = pkgs.mkShell rec {
      packages = devTools;
      LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath packages;
    };
  };
}
