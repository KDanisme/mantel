{
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = inputs.nixpkgs.lib.systems.flakeExposed;

      imports = with inputs; [
        flake-root.flakeModule
        treefmt-nix.flakeModule
        pre-commit-hooks.flakeModule
      ];

      perSystem = {
        pkgs,
        config,
        ...
      }: {
        pre-commit.settings.hooks.treefmt.enable = true;

        treefmt.config = {
          inherit (config.flake-root) projectRootFile;
          flakeCheck = false;
          programs = {
            alejandra.enable = true;
            prettier.enable = true;
            shellcheck.enable = true;
          };
        };

        devShells.default = pkgs.mkShell {
          inputsfrom = [config.pre-commit.devShell];
          packages = with pkgs; [
            zig_0_12
          ];
        };
      };
    };
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-root.url = "github:srid/flake-root";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
