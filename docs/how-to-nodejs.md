# Packaging Node.js Applications

This directory contains custom Nix packages for Home Manager. Below are the instructions for adding a new Node.js package using `node2nix`.

## Prerequisites

- `node2nix` must be available. You can run it via `nix-shell -p node2nix`.

## Steps

1.  **Create a Package Directory**
    Create a new directory inside `packages/` for your application (e.g., `packages/my-node-app`).

    ```bash
    mkdir packages/my-node-app
    cd packages/my-node-app
    ```

2.  **Define Dependencies**
    Create a `node-packages.json` file listing the npm packages you want to install.

    ```json
    [
      "my-node-app"
    ]
    ```

3.  **Generate Nix Expressions**
    Run `node2nix` to generate the necessary Nix files. We use specific flags to ensure consistency.

    ```bash
    nix-shell -p node2nix --run "node2nix -18 -i node-packages.json -c composition.nix -e node-env.nix"
    ```
    *   `-18`: Specifies Node.js version 18. Adjust if necessary.
    *   `-i node-packages.json`: Input file.
    *   `-c composition.nix`: Output composition file.
    *   `-e node-env.nix`: Output environment file.

4.  **Create Wrapper (`default.nix`)**
    Create a `default.nix` file to expose the package cleanly.

    ```nix
    { pkgs, nodejs ? pkgs.nodejs, ... }:

    let
      composition = import ./composition.nix {
        inherit pkgs nodejs;
        inherit (pkgs) system;
      };
    in
    composition.my-node-app
    ```
    *Replace `my-node-app` with the actual package name defined in step 2.*

5.  **Register in Packages Set**
    Add the new package to `packages/default.nix` so it is exposed both via the overlay and flake outputs.

    ```nix
    # packages/default.nix
    { pkgs }:
    {
      # ... existing packages
      my-node-app = pkgs.callPackage ./my-node-app/default.nix { };
    }
    ```

6.  **Build and Test**
    Verify the build before committing.

    ```bash
    nix build .#my-node-app
    ./result/bin/my-node-app --help
    rm result
    ```
