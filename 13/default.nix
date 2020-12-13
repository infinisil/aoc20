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
  r = a: b: c:
    let
      c' = lib.mod c b;
      go = x: l:
        if l == c' then x
        else go (x + 1) (lib.mod (l + a) b);
      result = go 0 0;
    in builtins.seq (builtins.trace "Computing with (${toString a}, ${toString b}, ${toString c})" null) (builtins.trace "Got ${toString result}" result);

  sequenceMatch = seq: match:
    let
      # Should be lowest common multiple, but we only have primes anyways
      newPeriod = seq.period * match.period;

      # seq.period * k + seq.offset = match.period * n + match.offset
      # seq.period * k + (seq.offset - match.offset) = match.period * n
      # seq.period * k = match.period * n - (seq.offset - match.offset)
      # a = seq.period, b = match.period, c = seq.offset - match.offset

      res = r seq.period match.period (seq.period + match.offset - seq.offset);
    in {
      period = newPeriod;
      offset = (res - 1) * seq.period + seq.offset;
    };

  inputSequences = lib.filter (s: s.period != null) (lib.imap0 (n: id: { period = id; offset = -n; }) input.ids);

  part2 = (lib.foldl' sequenceMatch initial (lib.tail inputSequences)).offset;

}
