import crew
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub type Joltages {
  Joltages(joltages: List(Int))
}

pub type State {
  State(lamps: List(Bool))
}

pub type Button {
  Button(toggles: List(Int))
}

pub type Machine {
  Machine(target: State, buttons: List(Button), joltages: Joltages)
}

pub fn parse(input: String) -> List(Machine) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    line
    |> string.split(" ")
    |> list.fold(Machine(State([]), [], Joltages([])), fn(acc, item) {
      let Machine(state, buttons, joltages) = acc

      case item {
        "[" <> state ->
          state
          |> string.drop_end(1)
          |> parse_state([])
          |> Machine(buttons, joltages)

        "(" <> button ->
          button
          |> string.drop_end(1)
          |> parse_int_list
          |> Button
          |> fn(button) { Machine(state, [button, ..buttons], joltages) }

        "{" <> joltages ->
          joltages
          |> string.drop_end(1)
          |> parse_int_list
          |> Joltages
          |> fn(joltages) { Machine(state, buttons, joltages) }

        "" -> acc

        other -> {
          echo other
          panic as "huh"
        }
      }
    })
  })
}

fn parse_state(state_string: String, acc) {
  case state_string {
    "." <> rest -> parse_state(rest, [False, ..acc])
    "#" <> rest -> parse_state(rest, [True, ..acc])
    _ -> State(acc |> list.reverse)
  }
}

fn parse_int_list(button_string: String) {
  button_string
  |> string.split(",")
  |> list.map(int.parse)
  |> result.values
}

pub fn pt_1(input: List(Machine)) {
  input
  |> list.fold(0, fn(sum, machine) {
    sum + pt_1_loop(machine, [#(machine.target, 0)], set.new())
  })
}

fn pt_1_loop(
  machine: Machine,
  last_states: List(#(State, Int)),
  next_states: Set(#(State, Int)),
) {
  case last_states {
    [] -> pt_1_loop(machine, next_states |> set.to_list, set.new())
    [#(state, num), ..rest] -> {
      // all off?
      case state.lamps |> list.all(fn(lamp) { !lamp }) {
        True -> num
        False -> {
          // click all buttons on this state
          machine.buttons
          |> list.fold(next_states, fn(next_states, button) {
            next_states
            |> set.insert(#(click_lamp_button(button, state), num + 1))
          })
          |> pt_1_loop(machine, rest, _)
        }
      }
    }
  }
}

fn click_lamp_button(button: Button, state: State) {
  state.lamps
  |> list.index_map(fn(lamp, index) {
    case button.toggles |> list.contains(index) {
      True -> !lamp
      False -> lamp
    }
  })
  |> State
}

pub fn pt_2(input: List(Machine)) {
  let pool_name = process.new_name("worker_pool")
  let assert Ok(_) =
    crew.new(pool_name, run_pt_2_loop_for_machine)
    |> crew.fixed_size(input |> list.length)
    |> crew.start()

  input
  |> crew.call_parallel(pool_name, 120_000, _)
  |> list.fold(0, int.add)
}

fn run_pt_2_loop_for_machine(machine: Machine) {
  pt_2_loop(
    machine,
    [
      #(
        list.repeat(0, times: list.length(machine.joltages.joltages))
          |> Joltages,
        0,
      ),
    ],
    set.new(),
  )
  |> echo
}

fn pt_2_loop(
  machine: Machine,
  last_joltages: List(#(Joltages, Int)),
  next_joltages: Set(#(Joltages, Int)),
) {
  case last_joltages {
    [] -> pt_2_loop(machine, next_joltages |> set.to_list, set.new())

    [#(joltages, num), ..rest] if num > 100 -> {
      echo machine

      num
    }
    [#(joltages, num), ..rest] -> {
      // all correct?
      case joltages.joltages == machine.joltages.joltages {
        True -> num
        False -> {
          // click all buttons on this state
          machine.buttons
          |> list.fold(next_joltages, fn(next_joltages, button) {
            next_joltages
            |> set.insert(#(click_joltage_button(button, joltages), num + 1))
          })
          |> pt_2_loop(machine, rest, _)
        }
      }
    }
  }
}

fn click_joltage_button(button: Button, joltages: Joltages) -> Joltages {
  joltages.joltages
  |> list.index_map(fn(joltage, index) {
    case button.toggles |> list.contains(index) {
      True -> joltage + 1
      False -> joltage
    }
  })
  |> Joltages
}
