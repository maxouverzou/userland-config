{
  devcontainer,
  lib,
  docker,
  docker-compose,
  git,
  nodejs_20,
}:
let
  nodejs = nodejs_20;
  # Home Manager relies on the host Docker installation, so we strip bundled Docker deps.
  removeDockerDeps = deps:
    lib.filter (dep: dep != docker && dep != docker-compose) deps;
in
devcontainer.overrideAttrs (oldAttrs: {
  buildInputs = removeDockerDeps (oldAttrs.buildInputs or [ ]);
  nativeBuildInputs = removeDockerDeps (oldAttrs.nativeBuildInputs or [ ]);
  propagatedBuildInputs = removeDockerDeps (oldAttrs.propagatedBuildInputs or [ ]);
  postInstall = ''
    makeWrapper "${lib.getExe nodejs}" "$out/bin/devcontainer" \
      --add-flags "$out/libexec/devcontainer.js" \
      --prefix PATH : ${lib.makeBinPath [ git ]}
  '';
})
