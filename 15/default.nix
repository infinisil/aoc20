rec {

  lib = import ~/src/nixpkgs/lib;

  #input = [ 16 11 15 0 1 7 ];

  speak = state: n: /*builtins.trace "[${toString (state.index + 1)}] Speaking ${toString n}"*/ {
    last = n;
    index = state.index + 1;
    log = arr.set state.last state.index state.log;
  };

  arr = import (fetchTarball {
    url = "https://github.com/infinisil/fastnixarray/archive/fd6215d4cf1a46d8599233ffb530f748bb3df185.tar.gz";
    sha256 = "0bjcyh56bms2za5gdx701871vha31qd07biz1z0ykh7gwlvlm6ay";
  });

  initialState = lib.foldl' speak {
    log = arr.emptyArray;
    last = lib.head input;
    index = 1;
  } (lib.tail input);

  next = state:
    let
      value = arr.get state.last state.log;
    in if builtins.isNull value then /*builtins.trace "${toString state.last} hasn't been spoken before, so we speak 0"*/ 0
    else state.index - value;
    #in /*builtins.trace "${toString state.last} has been spoken before at ${toString value}"*/ result;

  iterateUntil = cond: trans:
    let
      iterateUntilN = n: state: lib.foldl' (state: _:
        if cond state then state else trans state
      ) state (lib.genList throw n);

      go = n: state:
        if cond state then state
        else builtins.trace
          "Condition not successful yet after ${toString (n - 1)} iterations, going for another ${toString n}"
          (go (n * 2) (iterateUntilN n state));
    in go 1;

  # input = [ 3 1 2 ];

  input = [ 16 11 15 0 1 7 ];

  p = 10000;

  iterateN = n: trans: initial:
    lib.foldl' (acc: i:
      if lib.mod i p == 0 then builtins.trace "Progress: ${toString (i / p)}/${toString (n / p)}" (trans acc)
      else trans acc
    ) initial (lib.genList (i: i) n);

  runFor = n:
    let
      trans = state:
        let
          toSpeak = next state;
          new = speak state toSpeak;
        in builtins.seq new.log new;
      #final = iterateUntil (state: state.index >= n) trans initialState;
      final = iterateN (n - initialState.index) trans initialState;
    in final.last;

  part1 = runFor 2020;
  part2 = runFor 30000000;


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
