{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells = {
          default = pkgs.mkShell {
            packages = [
              pkgs.cargo
              pkgs.clippy
              pkgs.gcc
              pkgs.rustc
              pkgs.rustfmt
            ];
          };

          cross = pkgs.mkShell {
            packages = [
              pkgs.rustup
            ];
            shellHook = ''
              DATA_DIR="$PWD/.cross"
              mkdir -p "$DATA_DIR"

              export CARGO_HOME="$DATA_DIR/cargo"
              export RUSTUP_HOME="$DATA_DIR/rustup"
              export XARGO_HOME="$DATA_DIR/xargo"

              export PATH="$CARGO_HOME/bin:$PATH"

              rustup toolchain install ${pkgs.rustc.version} --profile minimal
              rustup default ${pkgs.rustc.version}

              cargo install cross
            '';
          };
        };

        packages = {
          default = self.packages.${system}.foobar;
          foobar = pkgs.rustPlatform.buildRustPackage {
            pname = "foobar";
            version = "git";
            src =
              let
                fs = pkgs.lib.fileset;
              in
              fs.toSource {
                root = ./.;
                fileset = fs.intersection (fs.gitTracked ./.) (
                  fs.unions [
                    ./src
                    ./Cargo.toml
                    ./Cargo.lock
                    ./README.md
                  ]
                );
              };
            cargoLock.lockFile = ./Cargo.lock;
          };
        };
      }
    );
}
