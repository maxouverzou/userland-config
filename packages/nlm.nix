{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "nlm";
  version = "0.0.0-20260104-9896589";

  src = fetchFromGitHub {
    owner = "tmc";
    repo = "nlm";
    rev = "98965898b828e24e93518bdcf86c167dab1e4577";
    hash = "sha256-U/hS65i9WZCHXKpWv0kuKtx9UQqlOgaCzB/0TaHM3yE=";
  };

  vendorHash = "sha256-HGDejtwcHfOTUGwXjqCpwbe1tsOwULBAvLwm1VramRM=";

  postPatch = ''
    cat >> internal/auth/chrome_linux.go <<EOF

func getBrowserPathForProfile(browserName string) string {
	if browserName == "Chromium" {
		if path, err := exec.LookPath("chromium"); err == nil {
			return path
		}
	}
	return getChromePath()
}

func getCanaryProfilePath() string {
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".config", "google-chrome-unstable")
}

func getBraveProfilePath() string {
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".config", "BraveSoftware", "Brave-Browser")
}
EOF
  '';

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Command line interface to NotebookLM";
    homepage = "https://github.com/tmc/nlm";
    license = lib.licenses.mit;
    mainProgram = "nlm";
  };
}
