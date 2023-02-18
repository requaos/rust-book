{
  description = "rust-tutorial";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    # nixpkgs.follows = "std/nixpkgs";
    std.url = "github:divnix/std";
    std.inputs.nixpkgs.follows = "nixpkgs";
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, std, ... } @ inputs: std.growOn
    {
      inherit inputs;
      systems = [ "x86_64-linux" ];
      cellsFrom = ./nix;
      cellBlocks = with std.blockTypes; [
        (devshells "devshells" { ci.build = true; })
        (installables "packages" { ci.build = true; })
        (runnables "packages" { ci.build = true; })
      ];
    }
    {
      devShells = std.harvest inputs.self [ "devshells" "devshells" ];
    };
}
