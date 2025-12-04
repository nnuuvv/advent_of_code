import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) -> List(Int) {
  let assert Ok(values) = {
    use values <- result.try(
      string.split(input, ",")
      |> list.map(string.split_once(_, "-"))
      |> result.all,
    )

    use values <- result.try(
      values
      |> list.map(fn(val) {
        use first <- result.try(int.parse(val.0))
        use second <- result.try(int.parse(val.1))

        Ok(#(first, second))
      })
      |> result.all,
    )

    let values = list.flat_map(values, fn(val) { list.range(val.0, val.1) })

    Ok(values)
  }
    as "Invalid input"

  values
}

pub fn pt_1(input: List(Int)) {
  input
  |> list.filter(filter_pt_1)
  |> list.fold(0, int.add)
}

fn filter_pt_1(value: Int) -> Bool {
  let value = int.to_string(value)
  let length = string.length(value)

  case int.is_odd(length) {
    True -> False
    False -> {
      let half =
        value
        |> string.drop_start(length / 2)
      string.starts_with(value, half)
    }
  }
}

pub fn pt_2(input: List(Int)) {
  input
  |> list.filter(pt_2_filter)
  |> list.fold(0, int.add)
}

fn pt_2_filter(value: Int) -> Bool {
  let value = int.to_string(value)
  let length = string.length(value)

  divisors(of: length, starting_at: length / 2, acc: [])
  |> list.any(fn(divisor) {
    let after_split_reassemble =
      value
      |> string.to_graphemes
      |> list.sized_chunk(length / divisor)
      |> list.map(list.fold(_, "", fn(a, b) { a <> b }))
      |> list.unique

    case after_split_reassemble {
      // there is one item left
      // and it isnt just the initial string split and reassembled
      [remaining] if remaining != value -> True
      _ -> False
    }
  })
}

fn divisors(
  of n: Int,
  starting_at potential_divisor: Int,
  acc acc: List(Int),
) -> List(Int) {
  case n % potential_divisor {
    _ if potential_divisor == 0 -> [n, ..acc]
    0 -> divisors(n, potential_divisor - 1, [potential_divisor, ..acc])
    _ -> divisors(n, potential_divisor - 1, acc)
  }
}
