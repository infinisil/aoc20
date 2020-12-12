rec {
  lib = import ~/src/nixpkgs/lib;
  input = lib.sort (a: b: a < b) (map lib.toInt (lib.splitString "\n" (lib.fileContents ./input)));

  input' = [ 0 ] ++ input ++ [ (lib.last input + 3) ];

  part1 =
    let
      differences = lib.zipListsWith (a: b: b - a) input' (lib.tail input');
      counts = lib.foldl' (acc: el: acc // { ${toString el} = acc.${toString el} or 0 + 1; }) {} differences;
    in counts."1" * counts."3";

  # List of booleans
  arrangements = list:
    let
      count = lib.genList (n:
        if ! lib.elemAt list n then 0
        else if n == 0 then 1
        else let
          a = if n < 3 then 0 else lib.elemAt count (n - 3);
          b = if n < 2 then 0 else lib.elemAt count (n - 2);
          c = if n < 1 then 0 else lib.elemAt count (n - 1);
        in a + b + c
      ) (lib.length list);
    in count;

  part2 =
    let
      booleanList = lib.genList (n: lib.elem n input') (lib.last input' + 1);
    in lib.last (arrangements booleanList);
}
