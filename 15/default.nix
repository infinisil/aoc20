rec {

  lib = import ~/src/nixpkgs/lib;

  #input = [ 16 11 15 0 1 7 ];

  speak = state: n: let ns = toString n; in /*builtins.trace "[${toString (state.index + 1)}] Speaking ${ns}"*/ {
    last = ns;
    index = state.index + 1;
    log = state.log // {
      ${state.last} = state.index;
    };
  };

  initialState = lib.foldl' speak {
    log = {};
    last = null;
    index = 0;
  } input;

  next = state:
    let firstTime = ! state.log ? ${state.last};
    in if firstTime then /*builtins.trace "${state.last} hasn't been spoken before, so we speak 0" */ 0
    else let result = state.index - state.log.${state.last};
    in /*builtins.trace "${state.last} has been spoken before at ${toString state.log.${state.last}}" */result;

  iterateUntil = cond: trans:
    let
      iterateUntilN = n: state: lib.foldl' (state: _:
        if cond state then state else trans state
      ) state (lib.genList throw n);

      go = n: state:
        if cond state then state
        else builtins.trace
          "Condition not successful yet after ${toString (n * 2 - 1)} iterations, going for another ${toString (n * 2)}"
          (go (n * 2) (iterateUntilN n state));
    in go 1;

  part1 =
    let
      trans = state:
        let
          toSpeak = next state;
          new = speak state toSpeak;
        in builtins.seq new.log new;
      final = iterateUntil (state: builtins.trace state.index state.index >= 100000) trans initialState;
    in lib.toInt final.last;


  speak2 = state: n: [ n state ];
  # [ 6 [ 3 [ 0 null ] ] ]


  #next2 = state:
  #  let
  #    initial = builtins.elemAt state 0;
  #    x = iterateUntil (v: builtins.isNull v || builtins.elemAt v 0 == initial) (v: builtins.elemAt v 1) (builtins.elemAt state 1);
  #    #go = i: state:
  #    #  if builtins.isNull state then 0
  #    #  else if builtins.elemAt state 0 == initial then i
  #    #  else go (i + 1) (builtins.elemAt state 1);
  #  in go 1 (builtins.elemAt state 1);


  input = [ 16 11 15 0 1 7 ];

  initial2 = lib.foldl' (acc: el: [ el acc ]) null input;

  # builtins.compile ?

  #test = next2 initial2;

  #res =
  #  let
  #    r = builtins.foldl' (acc: _: let x = next2 acc; in builtins.seq x [ x acc ]) initial2 (lib.genList throw (20200 - lib.length input));
  #  in builtins.elemAt r 0;


  # builtins.withMutable (a: 

  /*

  int arr[10000];
  while (...) {
  }

  builtins.get :: StateMonad Value
  builtins.put :: Value -> StateMonad ()

  builtins.bind :: m a -> (a -> m b) -> m b

  builtins.runState 

  builtins.mutableArrayLoop 1000 0 (get: set: exit: if get 0 == 10 then exit else set 0 (get 0 + 1))
  builtins.mutableArray 1000 0 (a: if a.get 0 == 10 then a.exit else a.set 1 (a.get 0 + 1))

  builtins.runMutableArray 1000 0 (arr: do {
    arr.set 10 10
    r <- arr.get 10
    return 10
  });

  builtins.mutableWhile (get: set: exit: if get 0 == true then exit else set 5 true) 100000 0
  */

  mutableArrayLoop = count: init: fun:
    let
      initial = lib.genList (_: init) count;
    in (iterateUntil (v: v.exit) (v:
      let
        get = lib.elemAt v.arr;
        set = i: v: { inherit i v; };
        res = fun get set {};
        newArr = lib.take res.i v.arr ++ [ res.v ] ++ lib.drop (res.i + 1) v.arr;
      in rec {
        exit = res == {};
        arr = if exit then v.arr else newArr;
      }
    ) { exit = false; arr = initial; }).arr;

  foo = mutableArrayLoop 10 0 (get: set: exit: if get 5 == 10 then exit else set 5 (get 5 + 1));


}
