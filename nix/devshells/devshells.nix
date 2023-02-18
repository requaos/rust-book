{ inputs, cell, ... }:
let
  inherit (inputs) nixpkgs;
  inherit (inputs.std) std lib;

  fenix = inputs.fenix.packages;

  l = nixpkgs.lib // builtins;

  rust-toolchain = with fenix; combine [
    complete.cargo
    complete.clippy
    complete.rustc
    complete.rust-src
    complete.rustfmt
    targets.wasm32-unknown-unknown.latest.rust-std
    rust-analyzer
    rust-analyzer-vscode-extension
  ];

  dev = lib.dev.mkShell {
    devshell.packages = with nixpkgs; [
      openssl
      openssl.dev
      clang
      llvm
      llvmPackages.libclang
      pkgconfig
      nodePackages.sass
    ]
    ++
    [
      rust-toolchain
    ];

    env = [{
      name = "RUST_SRC_PATH";
      value = "${rust-toolchain}/lib/rustlib/src/rust/library";
    }
    {
      name = "LIBCLANG_PATH";
      value = l.makeLibraryPath [ nixpkgs.llvmPackages.libclang.lib ];
    }
    {
      name = "PKG_CONFIG_PATH";
      value = "${nixpkgs.openssl.dev.outPath}/lib/pkgconfig:" + "$PKG_CONFIG_PATH";
    }
    ];


    commands = [
      {
        package = nixpkgs.treefmt;
        category = "repo tools";
      }
      {
        package = nixpkgs.alejandra;
        category = "repo tools";
      }
      {
        package = std.cli.default;
        category = "std";
      }
    ]
    ;
  };
in
{
  inherit dev;
  default = dev;
}
