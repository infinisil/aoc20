rec {
  lib = import ~/src/nixpkgs/lib;

  input = map lib.stringToCharacters (lib.splitString "\n" (lib.fileContents ./input));

  parseLine = line:
    let
      rowEntries = map (c: c == "B") (lib.take 7 line);
      columnEntries = map (c: c == "R") (lib.drop 7 line);
      entriesToNumber = lib.foldl' (acc: el: acc * 2 + (if el then 1 else 0)) 0;
      row = entriesToNumber rowEntries;
      column = entriesToNumber columnEntries;
    in row * 8 + column;

  passes = lib.sort (a: b: a > b) (map parseLine input);

  part1 = lib.head passes;

  part2 = lib.head (lib.concatLists (lib.zipListsWith (a: b: lib.optional (a - b == 2) (a - 1)) passes (lib.tail passes)));
}
