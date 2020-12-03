rec {
  lib = import ~/src/nixpkgs/lib;

  input = lib.splitString "\n" (lib.fileContents ./input);

  parseLine = line: map (c: c == "#") (lib.stringToCharacters line);

  parsedInput = map parseLine input;

  count = diffRow: diffColumn:
    let
      go = rowIndex: columnIndex:
        if rowIndex >= lib.length parsedInput then 0
        else
          let
            row = lib.elemAt parsedInput rowIndex;
            field = lib.elemAt row (lib.mod columnIndex (lib.length row));
            value = if field then 1 else 0;
            rest = go (rowIndex + diffRow) (columnIndex + diffColumn);
          in value + rest;
    in go 0 0;

  part1 = count 1 3;

  part2 = count 1 1 * count 1 3 * count 1 5 * count 1 7 * count 2 1;
  

}
