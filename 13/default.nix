rec {
  lib = import ~/src/nixpkgs/lib;

  input =
    let
      lines = lib.splitString "\n" (lib.fileContents ./input);
      parseId = c: if c == "x" then null else lib.toInt c;
    in {
      earliest = lib.toInt (lib.elemAt lines 0);
      ids = map parseId (lib.splitString "," (lib.elemAt lines 1));
    };

  
  part1 =
    let
      ids = lib.filter (i: i != null) input.ids;
      mods = map (i: {
        id = i;
        waitTime = i - lib.mod input.earliest i;
      }) ids;
      result = lib.head (lib.sort (a: b: a.waitTime < b.waitTime) mods);
    in result.id * result.waitTime;

  initial = {
    period = lib.head input.ids;
    offset = 0;
  };

  # Given a, b, c with 0 <= c < b
  # Returns first x that satisfies
  # a * x = b * y + c
  # Or
  # a * x =(modb) c
  r = a: b: c:
    let
      go = x: l:
        if l == c then builtins.trace "${toString a} * ${toString x} == ${toString l} == ${toString c} mod ${toString b}" x
        else builtins.trace "${toString a} * ${toString x} == ${toString l} != ${toString c} mod ${toString b}" go (x + 1) (lib.mod (l + a) b);
      x = go 0 0;
      y = (a * x - c) / b;
    in builtins.seq (builtins.trace "Computing the first x such that ${toString a} * x == ${toString b} * y + ${toString c}" null) (builtins.trace "Got x = ${toString x} and y = ${toString y}" (a * x));

  sequenceMatch = seq: match:
    let
      # Should be lowest common multiple, but we only have primes anyways
      newPeriod = seq.period * match.period;

      # seq.period * k + seq.offset = match.period * n + match.offset
      # seq.period * k + (seq.offset - match.offset) = match.period * n
      # seq.period * k = match.period * n - (seq.offset - match.offset)
      # a = seq.period, b = match.period, c = seq.offset - match.offset

      diff = seq.period - seq.offset;

      res = r seq.period match.period (lib.mod (match.offset + diff) match.period);
    in {
      period = newPeriod;
      offset = res - diff;
    };

  inputSequences = lib.filter (s: s.period != null) (lib.imap0 (n: id: { period = id; offset = -n; }) input.ids);

  part2 = (lib.foldl' sequenceMatch initial (lib.tail inputSequences)).offset;

  x = sequenceMatch { period = 17; offset = 0; } { period = 19; offset = -3; };

}
