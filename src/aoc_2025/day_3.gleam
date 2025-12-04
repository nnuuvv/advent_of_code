import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

pub fn parse(input: String) {
  string.split(input, "\n")
  |> list.map(string.to_graphemes)
  |> list.map(list.map(_, int.parse))
  |> list.map(parsed_to_batterybank)
}

fn parsed_to_batterybank(parsed: List(Result(Int, Nil))) {
  let assert Ok(value) = result.all(parsed)
  BatteryBank(value)
}

pub type BatteryBank {
  BatteryBank(batteries: List(Int))
}

pub fn pt_1(input: List(BatteryBank)) {
  input
  |> list.map(fn(battery_bank) {
    list.fold_right(battery_bank.batteries, #(0, 0), fn(largest, current) {
      case largest {
        // first loop
        #(0, 0) -> #(0, current)
        // second loop
        #(0, last) -> #(current, last)
        #(ten_spot, one_spot) if current >= ten_spot && ten_spot > one_spot -> #(
          current,
          ten_spot,
        )
        #(ten_spot, one_spot) if current >= ten_spot && ten_spot <= one_spot -> #(
          current,
          one_spot,
        )
        _ -> largest
      }
    })
  })
  |> list.map(fn(pair) { pair.0 * 10 + pair.1 })
  |> list.fold(0, int.add)
}

pub fn pt_2(input: List(BatteryBank)) {
  input
  |> list.map(fn(bank) {
    let length = list.length(bank.batteries)

    let #(left_to_check, initial_selection) =
      bank.batteries
      |> list.split(length - 12)

    loop(left_to_check:, initial_selection:, acc: [])
    |> list.fold(#(1, 0), fn(acc, current_value) {
      let #(multiplier, accumulated_value) = acc

      #(multiplier * 10, accumulated_value + current_value * multiplier)
    })
    |> pair.second
  })
  |> list.fold(0, int.add)
}

fn loop(
  left_to_check left_to_check,
  initial_selection initial_selection,
  acc result_selected,
) {
  case initial_selection {
    [] -> result_selected
    [current, ..rest] -> {
      let left_to_check = list.reverse(left_to_check)

      let #(result, left_to_check) = inner_loop(current, left_to_check, [], [])

      // echo result as "selected"

      loop(left_to_check, rest, [result, ..result_selected])
    }
  }
}

fn inner_loop(current, left_to_check, discard, passed_cause_smaller) {
  // echo left_to_check as "left"
  case left_to_check {
    // nothing left to check, return selection and discard
    [] -> #(current, discard)
    // head >= current -> discard current, head is new current
    [head, ..tail] if head >= current ->
      inner_loop(
        head,
        tail,
        list.append(passed_cause_smaller, [current, ..discard]),
        [],
      )
    // head < current -> temp_discard head, keep current
    [head, ..tail] if head < current ->
      inner_loop(current, tail, discard, [head, ..passed_cause_smaller])

    [_, ..] -> panic as "what"
  }
}
