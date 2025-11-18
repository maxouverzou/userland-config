{ writers, ... }:
writers.writePython3Bin "urlencode" {} ''
  import urllib.parse
  import sys

  if __name__ == "__main__":
      try:
          print(urllib.parse.quote(" ".join(sys.argv[1:])))
      except Exception as e:
          raise SystemExit(e)
''
