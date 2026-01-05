# notebooklm-mcp

This package is generated using `node2nix`.

## Updating the package

To update the package to the latest version, run the following command in this directory:

```bash
nix run nixpkgs#node2nix -- -i node-packages.json -o node-packages.nix -c composition.nix -e node-env.nix
```

If you want to target a specific version, update `node-packages.json` first.

To build the package:

```bash
nix-build -E 'with import <nixpkgs> { overlays = [ (import ../../overlays/default.nix) ]; }; notebooklm-mcp'
```
