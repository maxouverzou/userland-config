{ writers, python3Packages, ... }:
writers.writePython3Bin "yaml2json" { libraries = [ python3Packages.pyyaml ]; } ''
  import argparse
  import json
  import sys
  import yaml


  def main():
      parser = argparse.ArgumentParser()
      parser.add_argument('infile', nargs='?', default='-')
      parser.add_argument('outfile', nargs='?', default=None)

      options = parser.parse_args()

      if options.infile == '-':
          infile = sys.stdin
      else:
          infile = open(options.infile, encoding='utf-8')

      try:
          objs = yaml.safe_load(infile)
      finally:
          if infile is not sys.stdin:
              infile.close()

      if options.outfile is None:
          outfile = sys.stdout
      else:
          outfile = open(options.outfile, 'w', encoding='utf-8')

      with outfile:
          json.dump(objs, outfile, default=str)


  if __name__ == '__main__':
      try:
          main()
      except Exception as e:
          raise SystemExit(e)
''
