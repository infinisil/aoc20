rec {
  lib = import ~/src/nixpkgs/lib;

  input = lib.splitString "\n" (lib.fileContents ./input);

  parseLine = line:
    let
      words = lib.splitString " " line;
      counts = lib.splitString "-" (lib.elemAt words 0);
    in {
      low = lib.toInt (lib.elemAt counts 0);
      high = lib.toInt (lib.elemAt counts 1);
      letter = lib.removeSuffix ":" (lib.elemAt words 1);
      pass = lib.elemAt words 2;
    };

  valid1 = { low, high, letter, pass }:
    let
      count = lib.length (lib.filter (c: c == letter) (lib.stringToCharacters pass));
    in low <= count && count <= high;

  parsedInput = map parseLine input;

  part1 = lib.length (lib.filter valid1 parsedInput);

  valid2 = { low, high, letter, pass }:
    let
      chars = lib.stringToCharacters pass;
      first = lib.elemAt chars (low - 1) == letter;
      second = lib.elemAt chars (high - 1) == letter;
    in first != second;

  part2 = lib.length (lib.filter valid2 parsedInput);
}

