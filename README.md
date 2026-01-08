# userland-config

```bash
# update locally
nh home switch ~/.config/home-manager

# update remotely
nix-shell -p nh --run "nh home switch github:maxouverzou/userland-config -- --refresh"

# list direct dependencies
nix-store --query --references $(which devcontainer)

# build a custom package (flake output)
nix build .#my-package
```

## Troubleshooting

### Missing attribute `activationPackage` on Darwin

See [homemanager issue](https://github.com/nix-community/home-manager/issues/2678#issuecomment-2481495068)

### ServiceUnknown: The name ca.desrt.dconf was not provided by any .service files

> GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: The name ca.desrt.dconf was not provided by any .service files

- cause: gtk is installed but `programs.dconf.enable = false` (?)
- fix: `programs.dconf.enable = true` (?)
