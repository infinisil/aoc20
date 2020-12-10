rec {
  lib = import ~/src/nixpkgs/lib;

  parseLine = line:
    let
      m = builtins.match "(...) (.)([0-9]+)" line;
      num = lib.toInt (lib.elemAt m 2);
    in {
      operation = lib.elemAt m 0;
      argument = if lib.elemAt m 1 == "+" then num else -num;
      __toString = self: "${self.operation} ${toString self.argument}";
    };

  input = map parseLine (lib.splitString "\n" (lib.fileContents ./input));

  initialState = {
    # program counter
    programCounter = 0;
    # Instructions that were already executed
    instructionSet = {};
    accumulator = 0;
  };

  stateTransform = program: state:
    let
      instruction = lib.elemAt program state.programCounter;
      baseState = {
        programCounter = state.programCounter + 1;
        instructionSet = state.instructionSet // {
          ${toString state.programCounter} = null;
        };
        accumulator = state.accumulator;
      };

      nextState = builtins.trace (toString instruction) {
        acc = baseState // {
          accumulator = state.accumulator + instruction.argument;
        };
        jmp = baseState // {
          programCounter = state.programCounter + instruction.argument;
        };
        nop = baseState;
      }.${instruction.operation};

    in if state.programCounter >= lib.length input then state // { result = "end-of-program"; }
    else if state.instructionSet ? ${toString state.programCounter} then state // { result = "infinite-loop"; }
    else builtins.trace (showState state) nextState;

  iterateUntilRecursive = cond: trans:
    let
      go = state:
        if cond state then state
        else go (trans state);
    in go;

  # Like iterateUntilRecursive, but doesn't suffer from stack overflow problems
  # While not necessary for this challenge, might be useful elsewhere
  iterateUntil = cond: trans:
    let
      iterateUntilN = n: state: lib.foldl' (state: _:
        if cond state then state else trans state
      ) state (lib.genList throw n);

      go = n: state:
        if cond state then state
        else go (n * 2) (iterateUntilN n state);
    in go 1;


  showState = state: "(pc: ${toString state.programCounter}; acc: ${toString state.accumulator})";

  runProgram = program: iterateUntil (state: state ? result) (stateTransform program) initialState;

  part1 = (runProgram input).accumulator;

  endResultForChangedN = n:
    let
      oldInstruction = lib.elemAt input n;
      newInstruction = oldInstruction // {
        operation = if oldInstruction.operation == "nop" then "jmp" else "nop";
        __toString = self: oldInstruction.__toString self + " (changed)";
      };
      newProgram = lib.take n input ++ [ newInstruction ] ++ lib.drop (n + 1) input;
      programResult = runProgram newProgram;
    in
      if oldInstruction.operation == "acc" then null
      else if programResult.result == "infinite-loop" then null
      else programResult.accumulator;

  part2 = lib.foldl' (acc: n: if acc != null then acc else endResultForChangedN n) null (lib.genList lib.id (lib.length input));
}
