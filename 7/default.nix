rec {
  lib = import ~/src/nixpkgs/lib;

  input = lib.splitString "\n" (lib.fileContents ./input);

  parseLine = line:
    let
      mainMatch = builtins.match "([a-z]+ [a-z]+) bags contain (.*)\\." line;
      color = lib.elemAt mainMatch 0;
      subs = lib.splitString ", " (lib.elemAt mainMatch 1);
      subMatches = lib.listToAttrs (lib.concatMap (sub:
        let subMatch = builtins.match "([0-9]+) ([a-z]+ [a-z]+) bags?" sub;
        in if subMatch == null then [] else [
          (lib.nameValuePair (lib.elemAt subMatch 1) (lib.toInt (lib.elemAt subMatch 0)))
        ]) subs);
    in lib.nameValuePair color subMatches;

  parsedInput = lib.listToAttrs (map parseLine input);

  canContainShinyGold = lib.mapAttrs (name: subs:
    lib.any (sub: sub == "shiny gold" || canContainShinyGold.${sub}) (lib.attrNames subs)
  ) parsedInput;

  part1 = lib.length (lib.filter lib.id (lib.attrValues canContainShinyGold));

  bagCount = lib.mapAttrs (name: subs:
    lib.foldl' (acc: sub: let value = subs.${sub}; in
      acc + value + value * bagCount.${sub}
    ) 0 (lib.attrNames subs)
  ) parsedInput;

  part2 = bagCount."shiny gold";


}
