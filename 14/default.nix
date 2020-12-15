rec {
  lib = import ~/src/nixpkgs/lib;

  parseLine = line:
    let
      m = builtins.match "([a-z]+)(\\[([0-9]+)])? = (.*)" line;
    in {
      mem = {
        op = "mem";
        address = lib.toInt (lib.elemAt m 2);
        value = lib.toInt (lib.elemAt m 3);
      };
      mask = {
        op = "mask";
        value = lib.elemAt m 3;
      };
    }.${lib.elemAt m 0};

  input = map parseLine (lib.splitString "\n" (lib.fileContents ./input));

  initialState = {
    # 0 iff mask is 0 or X
    mask0 = 0;
    # 1 iff mask is 1 or X
    mask1 = 0;

    memory = {};
  };

  parseMask = mask:
    let
      chars = lib.stringToCharacters mask;
      mask0 = lib.foldl' (acc: el: 2 * acc + (if el == "1" then 1 else 0)) 0 chars;
      mask1 = lib.foldl' (acc: el: 2 * acc + (if el == "0" then 0 else 1)) 0 chars;
    in {
      inherit mask0 mask1;
    };

  /*
  input  0 1  0 1  0 1
  mask0  0 0  0 0  1 1
  mask1  0 0  1 1  1 1
  want   0 0  0 1  1 1  =  mask0 || (input && mask1)
  */
  applyMask = mask: input:
    lib.bitOr (lib.bitAnd mask.mask1 input) mask.mask0;

  stateTransform1 = state: instr: {
    mask = state // parseMask instr.value;
    mem = state // {
      memory = state.memory // {
        ${toString instr.address} = applyMask state instr.value;
      };
    };
  }.${instr.op};

  sum = lib.foldl' builtins.add 0;

  part1 =
    let finalState = lib.foldl' stateTransform1 initialState input;
    in sum (lib.attrValues finalState.memory);



  printBits = n: (lib.foldl' ({ n, r }: _: { n = n / 2; r = (if lib.mod n 2 == 0 then "0" else "1") + r; }) { inherit n; r = ""; } (lib.genList throw 36)).r;

  memoryAddresses = mask: input:
    let
      /*
      input    0 1  0 1  0 1
      mask0    0 0  0 0  1 1
      mask1    0 0  1 1  1 1
      floating 0 0  1 1  0 0  =  mask0 xor mask1
      base     0 1  0 0  1 1  =  (NOT out3) && (input || mask0)
      */
      # Has all bits that are floating set to 1
      floating = lib.bitXor mask.mask0 mask.mask1;
      # The first memory address, where all floating bits are 0
      base = lib.bitAnd (lib.bitNot floating) (lib.bitOr input mask.mask0);

      # Iteratively duplicates all addresses if the latest floating bit is 1
      result = lib.foldl' ({ floating, addrs, power }: _:
        let
          f = lib.mod floating 2 == 1;
          newAddrs = lib.concatMap (addr: [ addr ] ++ [ (lib.bitOr addr power) ]) addrs;
        in {
          floating = floating / 2;
          addrs = if f then newAddrs else addrs;
          power = power * 2;
        }
      ) {
        # The current floating number, shifted one to the right for every iteration
        inherit floating;
        # The power of the last floating bit, doubled every iteration
        power = 1;
        # The resulting addreses, starting with the base one
        addrs = [ base ];
      } (lib.genList throw 36);
    in result.addrs;

  stateTransform2 = state: instr: {
    mask = state // parseMask instr.value;
    mem = state // {
      memory = state.memory // lib.listToAttrs (map (addr: lib.nameValuePair (toString addr) instr.value) (memoryAddresses state instr.address));
    };
  }.${instr.op};

  part2 =
    let finalState = lib.foldl' stateTransform2 initialState input;
    in sum (lib.attrValues finalState.memory);
}
