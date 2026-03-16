# Packaging Node.js Applications

This directory contains custom Nix packages for Home Manager. Below are the instructions for adding a new Node.js package using `buildNpmPackage`.

## Steps

1.  **Create a Package Directory**
    Create a new directory inside `packages/` for your application.

    ```bash
    mkdir packages/my-node-app
    cd packages/my-node-app
    ```

2.  **Obtain `package-lock.json`**
    `buildNpmPackage` requires a `package-lock.json` to fetch dependencies reproducibly. Download the tarball from npm and extract it:

    ```bash
    # Download and extract the tarball to get package.json
    curl -sL https://registry.npmjs.org/my-node-app/-/my-node-app-<version>.tgz | tar xz --strip-components=1 package/package.json
    # Generate the lock file
    npm install --package-lock-only
    cp package-lock.json packages/my-node-app/package-lock.json
    ```

    Alternatively, if you have the source checked out locally, copy its existing `package-lock.json` directly.

3.  **Get the hashes**
    Compute the two hashes needed by Nix. Start with placeholder hashes, then fix them from the build error output:

    - `hash` (for the tarball): run `nix-prefetch-url --type sha256 https://registry.npmjs.org/my-node-app/-/my-node-app-<version>.tgz` and convert with `nix hash convert --hash-algo sha256 --to sri <hex-hash>`
    - `npmDeps` hash: set to `sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=` initially, then copy the correct hash from the error message after a failed build.

4.  **Create `default.nix`**

    ```nix
    { pkgs, lib, ... }:

    pkgs.buildNpmPackage rec {
      pname = "my-node-app";
      version = "1.2.3";

      src = pkgs.fetchurl {
        url = "https://registry.npmjs.org/my-node-app/-/my-node-app-${version}.tgz";
        hash = "sha256-<tarball-hash>=";
      };

      npmDeps = pkgs.fetchNpmDeps {
        src = ./.;
        hash = "sha256-<npmDeps-hash>=";
      };

      postPatch = ''
        cp ${./package-lock.json} package-lock.json
      '';

      # Uncomment if the package has no build step:
      # dontNpmBuild = true;

      # Uncomment if needed:
      # npmFlags = [ "--legacy-peer-deps" ];

      # If postinstall scripts try to download binaries (e.g. playwright, onnxruntime),
      # skip all scripts and rebuild native addons manually:
      # nativeBuildInputs = with pkgs; [ python3 pkg-config nodePackages.node-gyp ];
      # npmFlags = [ "--ignore-scripts" ];
      # postBuild = ''
      #   pushd node_modules/some-native-addon
      #   node-gyp rebuild --nodedir=${pkgs.nodejs}/include/node
      #   popd
      # '';

      meta = with lib; {
        description = "Description of my-node-app";
        homepage = "https://github.com/example/my-node-app";
        license = licenses.mit;
        maintainers = [];
      };
    }
    ```

5.  **Register in Packages Set**
    Add the new package to `packages/default.nix`:

    ```nix
    my-node-app = pkgs.callPackage ./my-node-app/default.nix { };
    ```

6.  **Build and Test**

    ```bash
    nix build .#my-node-app
    ./result/bin/my-node-app --help
    rm result
    ```
