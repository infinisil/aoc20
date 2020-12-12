rec {
  lib = import ~/src/nixpkgs/lib;

  parseLine = line:
    let
      m = builtins.match "(.)(.*)" line;
    in {
      op = lib.elemAt m 0;
      value = lib.toInt (lib.elemAt m 1);
    };

  input = map parseLine (lib.splitString "\n" (lib.fileContents ./input));

  initialState1 = {
    dx = 1;
    dy = 0;
    x = 0;
    y = 0;
  };

  turnLeft = state: state // { dx = -state.dy; dy = state.dx; };
  turnRight = state: state // { dx = state.dy; dy = -state.dx; };

  nextState1 = state: instr: {
    N = state // { y = state.y + instr.value; };
    S = state // { y = state.y - instr.value; };
    E = state // { x = state.x + instr.value; };
    W = state // { x = state.x - instr.value; };
    L = lib.foldl' (state: _: turnLeft state) state (lib.genList throw (instr.value / 90));
    R = lib.foldl' (state: _: turnRight state) state (lib.genList throw (instr.value / 90));
    F = state // {
      x = state.x + instr.value * state.dx;
      y = state.y + instr.value * state.dy;
    };
  }.${instr.op};

  distance = state:
    (if state.x < 0 then -state.x else state.x)
    + (if state.y < 0 then -state.y else state.y);

  part1 =
    let
      result = lib.foldl' nextState1 initialState1 input;
    in distance result;

  initialState2 = {
    dx = 10;
    dy = 1;
    x = 0;
    y = 0;
  };

  nextState2 = state: instr: {
    N = state // { dy = state.dy + instr.value; };
    S = state // { dy = state.dy - instr.value; };
    E = state // { dx = state.dx + instr.value; };
    W = state // { dx = state.dx - instr.value; };
    L = lib.foldl' (state: _: turnLeft state) state (lib.genList throw (instr.value / 90));
    R = lib.foldl' (state: _: turnRight state) state (lib.genList throw (instr.value / 90));
    F = state // {
      x = state.x + instr.value * state.dx;
      y = state.y + instr.value * state.dy;
    };
  }.${instr.op};

  part2 =
    let
      result = lib.foldl' nextState2 initialState2 input;
    in distance result;

}
