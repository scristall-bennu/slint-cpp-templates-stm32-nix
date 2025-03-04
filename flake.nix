{
  description = "Slint C++ Bare Metal Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, rust-overlay }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

    in
    {
      devShells = builtins.listToAttrs (map (system: {
        name = system;
        value = let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              rust-overlay.overlays.default
              (final: prev: {
                unstable = import nixpkgs-unstable {
                  inherit system;
                };
              })
            ];
          };

          slint = pkgs.stdenv.mkDerivation rec {
            name = "slint";

            src = pkgs.fetchFromGitHub {
              owner = "scristall-bennu";
              repo = "slint";
              rev = "5bac14222fb8725fafb17918c623975a33c1d413";
              sha256 = "9NPW0hwYtPmXNHTSnNF4lXF1rwWsI7wNCFL6hzv5AlY=";
            };

            cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
              inherit src;
              hash = "sha256-V/ewx07fiNfSSI6eI7p3pZfczSCn5N7P7UmoxkKuYIs=";
            };

            buildInputs = with pkgs; [
              cargo
              rustPlatform.cargoSetupHook
              cmake
              gcc-arm-embedded
              unstable.corrosion
              ninja
              rust-cbindgen
              (rust-bin.stable."1.83.0".default.override {
                extensions = [ "rust-src" ];
                targets = [ "thumbv7em-none-eabihf" ];
              })
            ];

          buildPhase = ''
              # Build and install firmware target (thumbv8m.main-none-eabihf)
              mkdir -p build-fw
              cd build-fw
              cmake -DCMAKE_C_COMPILER=arm-none-eabi-gcc \
                    -DCMAKE_CXX_COMPILER=arm-none-eabi-g++ \
                    -DCMAKE_AR=arm-none-eabi-ar \
                    -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
                    -DRust_CARGO_TARGET=thumbv7em-none-eabihf \
                    -DSLINT_FEATURE_FREESTANDING=ON \
                    -DSLINT_FEATURE_EXPERIMENTAL=ON \
                    -DBUILD_SHARED_LIBS=OFF \
                    -DSLINT_FEATURE_RENDERER_SOFTWARE=ON \
                    -DCMAKE_INSTALL_PREFIX=$out \
                    -DCMAKE_BUILD_TYPE=Release \
                    -DCMAKE_SYSTEM_NAME=Generic \
                    -DCMAKE_SYSTEM_PROCESSOR=ARM \
                    --debug-find-pkg=Corrosion \
                    ..
              make
              make install
          '';

          dontUseCmakeConfigure = true;
          dontFixup = true;
          dontInstall = true;
        };

        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              gcc
              gnumake
              cmake
              git
              gcc-arm-embedded
              pkg-config
              rust-cbindgen
              (pkgs.rust-bin.stable."1.83.0".default.override {
                extensions = [ "rust-src" ];
                targets = [ "thumbv7em-none-eabihf" ];
              })
              fontconfig
              slint
            ];

            shellHook = ''
              export PATH=${pkgs.gcc-arm-embedded}/bin:$PATH

              # Clean up these variables -- they often confuse cross builds
              unset CMAKE_INCLUDE_PATH
              unset CMAKE_LIBRARY_PATH

              export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath (with pkgs; [ fontconfig ])}"
            '';
          };
        };
      }) systems);

    };
}
