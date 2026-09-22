# Flake for Cabra Lattice blog development environment
# Provides Ruby, Node.js, Jekyll, and CookCLI for building the blog

{
  description = "Development environment for Cabra Lattice blog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # Development shell
      devShells.${system}.default = pkgs.mkShell {
        name = "blog-dev";

        buildInputs = with pkgs; [
          # Ruby 3.4.x (matches .ruby-version ~3.2.3)
          ruby_3_4

          # Node.js 22.x (for npm/yarn and build scripts)
          nodejs_22

          # Cook CLI (Cooklang converter for recipes)
          cook-cli

          # Python 3 (for scripts and utilities)
          python3

          # Build dependencies
          gcc
          gnumake
          pkg-config

          # Additional tools
          curl
          git
        ];

        # Shell hook to set up the environment
        shellHook = ''
          echo "=== Cabra Lattice Blog Development Environment ==="

          # Create gem directory if it doesn't exist
          mkdir -p "$HOME/.nix-gems/lib"
          ln -sf ${pkgs.ruby_3_4}/lib/libruby-3.4.9.so.3.4.9 "$HOME/.nix-gems/lib/libruby.so.3.4" 2>/dev/null || true

          # Set up gem path and library path
          export GEM_HOME="$HOME/.nix-gems"
          export PATH="$GEM_HOME/bin:$PATH"
          export LD_LIBRARY_PATH="$HOME/.nix-gems/lib:$LD_LIBRARY_PATH"

          # Create directories for recipes if they don't exist
          mkdir -p _recipes
          mkdir -p previews

          echo ""
          echo "Available commands:"
          echo "  make install       # Install Ruby gems"
          echo "  make build         # Build the site"
          echo "  make serve         # Serve the site (with live reload)"
          echo "  make recipes       # Convert Cooklang recipes"
          echo "  make gen-previews  # Generate preview images"
          echo ""
        '';
      };

      # Package exports (for nix run, nix shell, etc.)
      packages.${system} = {
        ruby = pkgs.ruby_3_4;
        node = pkgs.nodejs_22;
        cook = pkgs.cook-cli;
      };
    };
}