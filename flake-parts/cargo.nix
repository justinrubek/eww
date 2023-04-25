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
    extraNativeBuildInputs = [
      pkgs.pkg-config
    ];
    withExtraNativeInputs = base: base ++ extraNativeBuildInputs;

    extraBuildInputs = [
      pkgs.gcc
      pkgs.gtk3
      pkgs.gtk-layer-shell
      pkgs.deno
      pkgs.mdbook
    ];
    withExtraBuildInputs = base: base ++ extraBuildInputs;

    craneLib = inputs.crane.lib.${system}.overrideToolchain self'.packages.rust-toolchain;

    common-build-args = rec {
      src = inputs.nix-filter.lib {
        root = ../.;
        include = [
          "crates"
          "Cargo.toml"
          "Cargo.lock"
        ];
      };

      pname = "eww";

      nativeBuildInputs = withExtraNativeInputs [];
      buildInputs = withExtraBuildInputs [];
      # LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath nativeBuildInputs;
    };

    deps-only = craneLib.buildDepsOnly ({} // common-build-args);

    packages = {
      eww = craneLib.buildPackage ({
          pname = "eww";
          cargoArtifacts = deps-only;
          cargoExtraArgs = "--bin eww";
          meta.mainProgram = "eww";
        }
        // common-build-args);

      eww-wayland = craneLib.buildPackage (rec {
          pname = "eww-wayland";
          cargoArtifacts = deps-only;
          cargoExtraArgs = "--bin eww --features wayland";
          meta.mainProgram = "eww";

          nativeBuildInputs = withExtraNativeInputs [];
          buildInputs = withExtraBuildInputs [];
        }
        // common-build-args);

      cargo-doc = craneLib.cargoDoc ({
          cargoArtifacts = deps-only;
        }
        // common-build-args);
    };

    checks = {
      clippy = craneLib.cargoClippy ({
          cargoArtifacts = deps-only;
          cargoClippyExtraArgs = "--all-features -- --deny warnings";
        }
        // common-build-args);

      rust-fmt = craneLib.cargoFmt ({
          inherit (common-build-args) src;
        }
        // common-build-args);

      rust-tests = craneLib.cargoNextest ({
          cargoArtifacts = deps-only;
          partitions = 1;
          partitionType = "count";
        }
        // common-build-args);
    };
  in rec {
    inherit packages checks;

    legacyPackages = {
      cargoExtraNativeBuildInputs = extraNativeBuildInputs;
      cargoExtraBuildInputs = extraBuildInputs;
    };
  };
}
