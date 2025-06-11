{ writers, python3Packages, ... }:
writers.writePython3Bin "json2yaml" { libraries = [ python3Packages.pyyaml ]; } ''
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
          objs = json.load(infile)
      finally:
          if infile is not sys.stdin:
              infile.close()

      if options.outfile is None:
          outfile = sys.stdout
      else:
          outfile = open(options.outfile, 'w', encoding='utf-8')

      with outfile:
          yaml.dump(objs, outfile)


  if __name__ == '__main__':
      try:
          main()
      except Exception as e:
          raise SystemExit(e)
''
