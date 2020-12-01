rec {
  lib = import ~/src/nixpkgs/lib;

  input = map lib.toInt (lib.splitString "\n" (lib.fileContents ./input));

  # Given a list of numbers and a number, find two numbers in the list that sum to the given number
  sumsTo = list: n:
    let
      a = lib.genAttrs (map toString list) (v: null);
      b = lib.genAttrs (map (v: toString (n - v)) list) (v: null);
      i = builtins.intersectAttrs a b;
    in map lib.toInt (lib.attrNames i);

  part1 = let r = sumsTo input 2020; in lib.elemAt r 0 * lib.elemAt r 1;

  sumsTo3 = list: n:
    let
      x = lib.concatMap (v: sumsTo (lib.remove v list) (n - v)) list;
    in lib.unique x;

  part2 = let r = sumsTo3 input 2020; in lib.elemAt r 0 * lib.elemAt r 1 * lib.elemAt r 2;
  

}
