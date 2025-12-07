import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/set
import gleam/string

pub fn parse(input: String) -> List(List(String)) {
  input
  // rows
  |> string.split("\n")
  // rows as chars
  |> list.map(string.to_graphemes)
}

pub fn pt_1(input: List(List(String))) {
  input
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

pub fn pt_2(input: List(List(String))) {
  input
  |> list.fold(dict.new(), fn(columns_with_beam, row) {
    let columns_with_beam =
      list.index_fold(
        row,
        columns_with_beam,
        fn(columns_with_beam, item, column) {
          case item {
            "S" -> columns_with_beam |> dict.upsert(column, add(_, 1))
            "^" -> {
              case dict.get(columns_with_beam, column) {
                Ok(count) if count > 0 -> {
                  // echo count
                  let columns_with_beam =
                    columns_with_beam
                    |> dict.delete(column)
                    |> dict.upsert(column - 1, add(_, count))
                    |> dict.upsert(column + 1, add(_, count))

                  columns_with_beam
                }

                _ -> columns_with_beam
              }
            }
            // "."
            _ -> columns_with_beam
          }
        },
      )

    columns_with_beam
  })
  |> dict.fold(0, fn(acc, _key, value) { acc + value })
}

fn add(item: option.Option(Int), amount) -> Int {
  let amount = case item {
    Some(count) -> count + amount
    None -> amount
  }

  case amount {
    amount if amount < 0 -> 0
    _ -> amount
  }
}
