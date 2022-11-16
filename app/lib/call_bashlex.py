import bashlex
import json
import sys

def ast_to_hash(ast):
  pos = ast.pos
  kind = ast.kind
  dictionary = {
    "pos": ast.pos,
    "kind": ast.kind,
  }
  if 'parts' in dir(ast):
    dictionary["parts"] = [ast_to_hash(part) for part in ast.parts]
  return dictionary

parts = bashlex.parse(sys.stdin.read())
json_hash = {
  "parts": [ast_to_hash(ast) for ast in parts]
}
print(json.dumps(json_hash))