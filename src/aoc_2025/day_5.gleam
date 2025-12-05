import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) -> #(List(#(Int, Int)), List(Int)) {
  let assert Ok(#(Ok(ranges), Ok(available))) = {
    use #(ranges, available) <- result.try(string.split_once(input, "\n\n"))

    let ranges =
      ranges
      |> string.split("\n")
      |> list.map(fn(range) {
        use #(start, end) <- result.try(string.split_once(range, "-"))

        use start <- result.try(int.parse(start))
        use end <- result.try(int.parse(end))

        Ok(#(start, end))
      })
      |> result.all()

    let available =
      available
      |> string.split("\n")
      |> list.map(int.parse)
      |> result.all()

    Ok(#(ranges, available))
  }
    as "Invalid input"

  #(ranges, available)
}

pub fn pt_1(input: #(List(#(Int, Int)), List(Int))) {
  let #(ranges, available) = input

  available
  |> list.fold(0, fn(acc, item) {
    let in_any_range =
      ranges
      |> list.any(fn(range) {
        case range {
          #(start, end) if item >= start && item <= end -> True
          _ -> False
        }
      })

    case in_any_range {
      True -> acc + 1
      False -> acc
    }
  })
}

pub fn pt_2(input: #(List(#(Int, Int)), List(Int))) {
  todo as "part 2 not implemented"
}
