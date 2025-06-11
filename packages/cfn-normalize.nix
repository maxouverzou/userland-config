{ writers, python3Packages, ... }:
writers.writePython3Bin "cfn-normalizer" { libraries = [ python3Packages.pyyaml ]; } ''
  import argparse
  import sys
  import yaml

  from functools import partial


  def generic_constructor(loader, node, get_name):
      classname = node.__class__.__name__
      if classname == "SequenceNode":
          constructor = loader.construct_sequence(node)
      elif classname == "MappingNode":
          constructor = loader.construct_mapping(node)
      else:
          constructor = loader.construct_scalar(node)

      return {get_name(node.tag): constructor}


  def to_getatt(loader, node):
      return {"Fn::GetAtt": node.value.split(".")}


  to_ref = partial(generic_constructor, get_name=lambda tag: "Ref")
  to_fn = partial(generic_constructor, get_name=lambda tag: f"Fn::{tag[1::]}")


  def get_loader():
      loader = yaml.SafeLoader
      loader.add_constructor("!Ref", to_ref)
      loader.add_constructor("!GetAtt", to_getatt)

      functions = ["Base64", "Cidr", "GetAZs", "ImportValue", "FindInMap",
                   "Join", "Select", "Split", "Sub", "And", "Equals", "If",
                   "Not", "Or", "Transform"]

      for function in functions:
          loader.add_constructor(f"!{function}", to_fn)

      return loader


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
          template = yaml.load(infile, Loader=get_loader())
      finally:
          if infile is not sys.stdin:
              infile.close()

      if options.outfile is None:
          outfile = sys.stdout
      else:
          outfile = open(options.outfile, 'w', encoding='utf-8')

      with outfile:
          yaml.dump(template, outfile)


  if __name__ == '__main__':
      try:
          main()
      except Exception as e:
          raise SystemExit(e)
''
