{ writeShellApplication, libarchive, ... }:
writeShellApplication {
  name = "cbr2cbz";
  runtimeInputs = [ libarchive ];
  bashOptions = [ "errexit" ];
  text = ''
    infile=$1

    if [[ -z "$infile" ]]; then
      echo "Error: infile is not set or is empty" >&2
      exit 1
    fi

    if [[ $infile != *.cbr ]]; then
      echo "Error: infile must end with .cbr" >&2
      exit 1
    fi

    if [[ ! -f "$infile" ]]; then
      echo "Error: File '$infile' does not exist" >&2
      exit 1
    fi

    outfile="''${infile%.cbr}.cbz"

    if [[ -f "$outfile" ]]; then
      echo "Error: File '$outfile' already exist" >&2
      exit 1
    fi

    bsdtar -cf "$outfile" --format=zip @"$infile"
  '';
}
