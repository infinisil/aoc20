rec {
  lib = import ~/src/nixpkgs/lib;

  parseTile = let mapping = {
    "." = 0;
    "L" = 1;
    "#" = 2;
  }; in v: mapping.${v};

  parseLine = line: map parseTile (lib.stringToCharacters line);

  input = map parseLine (lib.splitString "\n" (lib.fileContents ./input));

  height = lib.length input;
  width = lib.length (lib.elemAt input 0);

  borderRow = lib.genList (n: 0) (width + 2);
  borderedInput = [ borderRow ] ++ map (row: [ 0 ] ++ row ++ [ 0 ]) input ++ [ borderRow ];

  nextBoard = board:
    let
      occupiedCount = rowIndex: columnIndex:
        let
          list = lib.genList (n:
            let
              row = n / 3;
              column = n - 3 * row;
              row' = rowIndex + row;
              column' = columnIndex + column;
              value = lib.elemAt (lib.elemAt board row') column';
            in if value == 2 then 1 else 0
          ) 9;
        in lib.foldl' lib.add 0 list;

      newBoard = [ borderRow ] ++ lib.genList (row:
        [ 0 ] ++ lib.genList (column:
          let
            value = lib.elemAt (lib.elemAt board (row + 1)) (column + 1);
            count = occupiedCount row column;
          in
            if value == 1 && count == 0 then 2
            else if value == 2 && count >= 5 then 1
            else value
        ) width ++ [ 0 ]
      ) height ++ [ borderRow ];
    in newBoard;

  countOccupied = lib.foldl' (lib.foldl' (acc: tile: acc + (if tile == 2 then 1 else 0))) 0;

  part1 = countOccupied (lib.converge nextBoard borderedInput);

  nextBoard' = board:
    let
      directionMap = dRow: dColumn:
        let result = lib.genList (row: lib.genList (column: 
          let
            targetRow = row + dRow;
            targetColumn = column + dColumn;
            boardValue = lib.elemAt (lib.elemAt board targetRow) targetColumn;
            resultValue = lib.elemAt (lib.elemAt result targetRow) targetColumn;
          in
            if targetRow < 0 || height <= targetRow then false
            else if targetColumn < 0 || width <= targetColumn then false
            else if boardValue == 2 then true
            else if boardValue == 1 then false
            else resultValue
          ) width) height;
        in result;

      directions = [
        (directionMap (-1) (-1))
        (directionMap (-1) 0)
        (directionMap (-1) 1)
        (directionMap 0 (-1))
        (directionMap 0 1)
        (directionMap 1 (-1))
        (directionMap 1 0)
        (directionMap 1 1)
      ];

      occupiedCount = rowIndex: columnIndex:
        lib.foldl' (acc: dirMap:
          let occupied = lib.elemAt (lib.elemAt dirMap rowIndex) columnIndex;
          in acc + (if occupied then 1 else 0)
        ) 0 directions;

      newBoard = lib.genList (row:
        lib.genList (column:
          let
            value = lib.elemAt (lib.elemAt board row) column;
            count = occupiedCount row column;
          in
            if value == 1 && count == 0 then 2
            else if value == 2 && count >= 5 then 1
            else value
        ) width
      ) height;

    in newBoard;

  m = [ "." "L" "#" ];
  printBoard = board: builtins.trace ("\n" + lib.concatMapStringsSep "\n" (lib.concatMapStrings (lib.elemAt m)) board) board;

  part2 = countOccupied (lib.converge nextBoard' input);
}
