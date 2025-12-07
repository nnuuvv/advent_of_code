import gleam/dict
import gleam/list
import gleam/pair
import gleam/set
import gleam/string

pub fn pt_1(input: String) {
  input
  // rows
  |> string.split("\n")
  // rows as chars
  |> list.map(string.to_graphemes)
  |> list.fold(#(0, set.new()), fn(acc, row) {
    let #(split_sum, columns_with_beam) = acc

    let #(splits, columns_with_beam) =
      list.index_fold(row, #(0, columns_with_beam), fn(acc, item, column) {
        let #(split_sum, columns_with_beam) = acc

        case item {
          "S" | "|" -> #(split_sum, set.insert(columns_with_beam, column))
          "^" -> {
            case columns_with_beam |> set.contains(column) {
              True -> {
                let columns_with_beam =
                  columns_with_beam
                  |> set.delete(column)
                  |> set.insert(column - 1)
                  |> set.insert(column + 1)

                #(split_sum + 1, columns_with_beam)
              }
              False -> #(split_sum, columns_with_beam)
            }
          }
          // "."
          _ -> acc
        }
      })
    #(split_sum + splits, columns_with_beam)
  })
  |> pair.first()
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
