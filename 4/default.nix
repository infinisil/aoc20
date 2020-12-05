rec {
  lib = import ~/src/nixpkgs/lib;

  input = lib.fileContents ./input;

  passports = map (lib.replaceStrings [ "\n" ] [ " " ]) (lib.splitString "\n\n" input);

  passportFields = line:
    let
      entryPair = entry:
        let parts = lib.splitString ":" entry;
        in lib.nameValuePair (lib.elemAt parts 0) (lib.elemAt parts 1);
      entries = lib.listToAttrs (map entryPair (lib.splitString " " line));
    in entries;

  parsedInput = map passportFields passports;

  matches = regex: str: builtins.match regex str != null;

  schema = {
    byr = str: matches "[0-9]{4}" str && (lib.toInt str >= 1920 && lib.toInt str <= 2002);
    iyr = str: matches "[0-9]{4}" str && (lib.toInt str >= 2010 && lib.toInt str <= 2020);
    eyr = str: matches "[0-9]{4}" str && (lib.toInt str >= 2020 && lib.toInt str <= 2030);
    hgt = str:
      let
        res = builtins.match "([0-9]+)(cm|in)" str;
        value = lib.toInt (lib.elemAt res 0);
      in if res == null then false else {
        cm = value >= 150 && value <= 193;
        "in" = value >= 59 && value <= 76;
      }.${lib.elemAt res 1};
    hcl = matches "#[0-9a-f]{6}";
    ecl = str: lib.elem str [ "amb" "blu" "brn" "gry" "grn" "hzl" "oth" ];
    pid = matches "[0-9]{9}";
  };

  validPass = checkValues: pass: lib.all (name:
    pass ? ${name} && (checkValues -> schema.${name} pass.${name})
  ) (lib.attrNames schema);

  part1 = lib.length (lib.filter (validPass false) parsedInput);
  part2 = lib.length (lib.filter (validPass true) parsedInput);

}
