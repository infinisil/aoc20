rec {
  lib = import <nixpkgs/lib>;

  parseGroup = group: map (line: lib.genAttrs (lib.stringToCharacters line) (v: null)) (lib.splitString "\n" group);

  input = map parseGroup (lib.splitString "\n\n" (lib.fileContents ./input));

  reduceWith = op: lib.foldl' (acc: group:
    let result = lib.foldl' op (lib.head group) (lib.tail group);
    in acc + lib.length (lib.attrNames result)
  ) 0 input;

  part1 = reduceWith lib.mergeAttrs;
  part2 = reduceWith builtins.intersectAttrs;
}
