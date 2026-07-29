{
  description = "SMGUI Odin development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          isLinux = pkgs.stdenv.hostPlatform.isLinux;
          # Pin Odin separately from nixpkgs: this project needs Raylib 6 bindings,
          # while the nixpkgs revision remains old enough to support Intel macOS.
          raylib = pkgs.raylib.overrideAttrs (_: {
            version = "6.0";
            src = pkgs.fetchFromGitHub {
              owner = "raysan5";
              repo = "raylib";
              rev = "6.0";
              hash = "sha256-8+6MDTMc7Spix4ndAUzp51Q5iWcl7pQmyXuV2RutnOk=";
            };
            cmakeFlags = [
              "-DCUSTOMIZE_BUILD=ON"
              "-DSUPPORT_CUSTOM_FRAME_CONTROL=OFF"
              "-DPLATFORM=Desktop"
              "-DUSE_EXTERNAL_GLFW=ON"
              "-DINCLUDE_EVERYTHING=ON"
              "-DBUILD_SHARED_LIBS=ON"
            ];
          });
          odin = (pkgs.odin.override {
            llvmPackages_18 = pkgs.llvmPackages_21;
          }).overrideAttrs (_: {
            version = "dev-2026-07a";
            src = pkgs.fetchFromGitHub {
              owner = "odin-lang";
              repo = "Odin";
              tag = "dev-2026-07a";
              hash = "sha256-sjL6mj2zfUVpiwkooTTBCVkPRoPWR7ci/hb9TYF+J/I=";
            };
            patches = [
              ./nix/odin-darwin-remove-impure-links.patch
              ./nix/odin-system-raylib.patch
            ];
            postPatch = ''
              substituteInPlace src/build_settings.cpp \
                --replace-fail "arm64-apple-macosx" "arm64-apple-darwin"
              rm -r vendor/raylib/{linux,macos,wasm,windows}
              patchShebangs --build build_odin.sh
            '';
          });
        in
        {
          default = pkgs.mkShell {
            name = "smgui-dev";

            nativeBuildInputs = [
              pkgs.git
              pkgs.gnumake
              odin
              pkgs.pkg-config
            ];

            buildInputs = [
              pkgs.glfw
              raylib
            ] ++ pkgs.lib.optionals isLinux [
              pkgs.libGL
              pkgs.xorg.libX11
              pkgs.xorg.libXcursor
              pkgs.xorg.libXi
              pkgs.xorg.libXinerama
              pkgs.xorg.libXrandr
            ];

            shellHook = ''
              echo "SMGUI development environment ready:"
              echo "  Odin: $(odin version 2>/dev/null || true)"
              echo "  Run:  make check && make run"
              echo "  C:    make run-c"
            '';
          };
        });
    };
}
