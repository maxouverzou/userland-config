{ writeShellApplication, gemini-cli-bin }:

writeShellApplication {
  name = "gemini-podman";
  runtimeInputs = [ gemini-cli-bin ];
  runtimeEnv = {
    GEMINI_SANDBOX = "podman";
    GEMINI_SANDBOX_IMAGE = "us-docker.pkg.dev/gemini-code-dev/gemini-cli/sandbox:${gemini-cli-bin.version}";
    SANDBOX_FLAGS = "--security-opt label=disable --userns=keep-id";
  };
  text = ''
    exec gemini --sandbox "$@"
  '';
}