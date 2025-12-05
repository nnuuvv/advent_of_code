import gleam/dict
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) -> dict.Dict(#(Int, Int), Storage) {
  input
  |> string.split("\n")
  |> list.index_fold(dict.new(), fn(grid, row, row_index) {
    row
    |> string.to_graphemes()
    |> list.index_fold(grid, fn(grid, column, column_index) {
      let location = case column {
        "." -> Empty
        "@" -> Roll
        _ -> panic as "invalid input"
      }
      dict.insert(grid, #(row_index, column_index), location)
    })
  })
}

pub type Storage {
  Roll
  Empty
}

pub fn pt_1(warehouse: dict.Dict(#(Int, Int), Storage)) {
  warehouse
  |> dict.filter(fn(coord, storage) { can_access(warehouse, coord, storage) })
  |> dict.values()
  |> list.length()
}

fn can_access(warehouse, coord, storage) {
  case storage {
    Empty -> False
    Roll -> {
      let #(row, column) = coord

      // top row
      let top_left =
        dict.get(warehouse, #(row - 1, column - 1))
        |> result.unwrap(Empty)
      let top_middle =
        dict.get(warehouse, #(row - 1, column))
        |> result.unwrap(Empty)
      let top_right =
        dict.get(warehouse, #(row - 1, column + 1))
        |> result.unwrap(Empty)

      // both sides
      let left_middle =
        dict.get(warehouse, #(row, column - 1))
        |> result.unwrap(Empty)
      let right_middle =
        dict.get(warehouse, #(row, column + 1))
        |> result.unwrap(Empty)

      // bottom row
      let bottom_left =
        dict.get(warehouse, #(row + 1, column - 1))
        |> result.unwrap(Empty)
      let bottom_middle =
        dict.get(warehouse, #(row + 1, column))
        |> result.unwrap(Empty)
      let bottom_right =
        dict.get(warehouse, #(row + 1, column + 1))
        |> result.unwrap(Empty)

      [
        top_left,
        top_middle,
        top_right,
        left_middle,
        right_middle,
        bottom_left,
        bottom_middle,
        bottom_right,
      ]
      |> list.count(fn(item) { item == Roll })
      < 4
    }
  }
}

pub fn pt_2(warehouse: dict.Dict(#(Int, Int), Storage)) {
  pt_2_loop(warehouse, 0)
}

fn pt_2_loop(warehouse, count) {
  let accessible =
    warehouse
    |> dict.filter(fn(coord, storage) { can_access(warehouse, coord, storage) })
    |> dict.keys()

  case accessible {
    [] -> count
    _ -> {
      let warehouse = warehouse |> dict.drop(accessible)
      pt_2_loop(warehouse, count + list.length(accessible))
    }
  }
}
