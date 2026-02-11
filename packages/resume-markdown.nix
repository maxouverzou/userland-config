{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "resume-markdown";
  version = "1.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mikepqr";
    repo = "resume-markdown";
    rev = "v${version}";
    hash = "sha256-QMs0aA/dPFnigRGT6I0cHx8GFNY3t3YYSwOlmOAVdnk=";
  };

  build-system = [ python3Packages.hatchling ];

  dependencies = [ python3Packages.markdown ];

  meta = {
    description = "Write your resume in Markdown, style it with CSS, output to HTML and PDF";
    homepage = "https://github.com/mikepqr/resume-markdown";
    license = lib.licenses.mit;
    mainProgram = "resume-markdown";
  };
}
