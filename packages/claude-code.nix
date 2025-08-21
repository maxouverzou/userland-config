{
  claude-code,
  fetchurl,
  ...
}:
claude-code.overrideAttrs (oldAttrs: rec {
  # https://github.com/anthropics/claude-code/issues/6105
  version = "1.0.81";
  src = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
    hash = "sha256-nlMmdGstMWXYtcIDuLL3ygQEg0cbFeCJakYO8IAerf4=";
  };
})
