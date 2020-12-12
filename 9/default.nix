rec {
  lib = import ~/src/nixpkgs/lib;

  input = map lib.toInt (lib.splitString "\n" (lib.fileContents ./input));

  check = list: start: length: number:
    let
      set = lib.listToAttrs (lib.genList (n: lib.nameValuePair (toString (lib.elemAt list (start + n))) null) length);
      inverseSet = lib.listToAttrs (lib.genList (n: lib.nameValuePair (toString (number - lib.elemAt list (start + n))) null) length);
    in builtins.trace "Checking with start ${toString start}, length ${toString length} and number ${toString number}" builtins.intersectAttrs set inverseSet != {};

  checkList = list: length: lib.genList (n: 
    let number = lib.elemAt list (n + length);
    in {
      inherit number;
      success = check list n length number;
    }
  ) (lib.length list - length);

  part1 = (lib.findFirst (n: ! n.success) (throw "No non-successes") (checkList input 25)).number;

  prefixSums = list:
    let result = lib.genList (n: (if n == 0 then 0 else lib.elemAt result (n - 1)) + lib.elemAt list n) (lib.length list);
    in result;

  result =
    let
      p = prefixSums input;
      p' = map (n: n - part1) p;
      s = lib.listToAttrs (lib.genList (n: lib.nameValuePair (toString (lib.elemAt p n)) n) (lib.length p));
      s' = lib.listToAttrs (lib.genList (n: lib.nameValuePair (toString (lib.elemAt p' n)) n) (lib.length p'));
      name = lib.elemAt (lib.attrNames (lib.filterAttrs (n: v: s'.${n} - s.${n} != 1) (builtins.intersectAttrs s s'))) 0;
      range = lib.sort (a: b: a < b) (lib.sublist (s.${name} + 1) (s'.${name} - s.${name}) input);
      result = lib.head range + lib.last range;
    in result;


}
