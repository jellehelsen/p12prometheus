{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = { self, nixpkgs, poetry2nix }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (system: {
        default = pkgs.${system}.poetry2nix.mkPoetryApplication {
          projectDir = self;
          python = pkgs.${system}.python311Full;
        };
      });

      devShells = forAllSystems (system: {
        default = pkgs.${system}.mkShellNoCC {
          shellHook = ''
            envpath=$(poetry env info -p)
            source $envpath/bin/activate
          '';
          packages = with pkgs.${system}; [
            python311Packages.python-lsp-server
            python311Packages.python-lsp-black
            python311Packages.pyls-isort
            python311Packages.python-lsp-ruff
            poetry
            entr
            pre-commit
            ruff
            buildpack
          ];
        };
      });
    };
}
