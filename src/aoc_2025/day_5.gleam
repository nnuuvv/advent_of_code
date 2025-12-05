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
  let #(ranges, _) = input

  let sum =
    ranges
    // |> echo
    |> list.fold([], fn(processed, range) { pt_2_loop(range, processed, []) })
    |> list.fold(0, fn(sum, range) {
      case range {
        #(0, 0) -> sum
        #(start, end) -> {
          sum + { { end - start } + 1 }
        }
      }
    })

  sum
}

pub fn pt_2_loop(range, processed_ranges: List(#(Int, Int)), acc) {
  let #(start, end) = range

  case processed_ranges {
    // we've gone through all of them
    // add range to acc for next round of processing
    [] -> [range, ..acc]
    // fully fits into a different range, we are done
    [p_range, ..rest] if p_range.0 <= start && p_range.1 >= end ->
      list.append([p_range, ..acc], rest)

    // already processed one fits fully 
    [p_range, ..rest] if p_range.0 >= start && p_range.1 <= end ->
      pt_2_loop(range, rest, acc)

    // merge at front
    [#(p_start, p_end), ..rest] if start >= p_start && start <= p_end ->
      pt_2_loop(#(p_start, end), rest, acc)

    // merge at end
    [#(p_start, p_end), ..rest] if end >= p_start && end <= p_end ->
      pt_2_loop(#(start, p_end), rest, acc)

    // keep the unmatched
    [unmatched, ..rest] -> pt_2_loop(range, rest, [unmatched, ..acc])
  }
}
