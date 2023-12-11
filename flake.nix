{
  description = "Application packaged using poetry2nix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # see https://github.com/nix-community/poetry2nix/tree/master#api for more functions and examples.
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryApplication mkPoetryEnv defaultPoetryOverrides;
        override = self: super: {
          dlms-cosem = super.dlms-cosem.overridePythonAttrs(
            old: {
              buildInputs = (old.buildInputs or [ ]) ++ [ super.setuptools-scm ];
            }
          );
        };
      in
      {
        packages = {
          myapp = mkPoetryApplication {
            projectDir = self;
            overrides = defaultPoetryOverrides.extend(override);
          };
          default = self.packages.${system}.myapp;
        };

        devShells.default = pkgs.mkShell {
          # inputsFrom = [ self.packages.${system}.myapp ];
          shellHook = ''
            envpath=$(poetry env info -p)
            source $envpath/bin/activate
          '';

          packages = with pkgs; [
            python311Packages.python-lsp-server
            python311Packages.python-lsp-black
            python311Packages.pyls-isort
            python311Packages.python-lsp-ruff
            python311Packages.setuptools
            poetry
            entr
            pre-commit
            ruff
            buildpack
          ];
        };
      });
}
