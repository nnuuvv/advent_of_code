import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) -> List(Rotation) {
  let lines = string.split(input, "\n")
  list.map(lines, fn(line) {
    case line {
      "L" <> amount -> {
        let assert Ok(amount) = int.parse(amount)
        Left(amount)
      }
      "R" <> amount -> {
        let assert Ok(amount) = int.parse(amount)
        Right(amount)
      }
      _ -> {
        echo line
        panic as "Invalid input o.o"
      }
    }
  })
}

pub type Rotation {
  Left(amount: Int)
  Right(amount: Int)
}

pub fn pt_1(input: List(Rotation)) {
  pt_1_loop(input, 50, 0)
}

fn pt_1_loop(input: List(Rotation), position: Int, zero_count: Int) -> Int {
  case input {
    [] -> zero_count
    [rotation, ..rest] ->
      case do_rotation_pt_1(position, rotation) {
        0 -> pt_1_loop(rest, 0, zero_count + 1)
        otherwise -> pt_1_loop(rest, otherwise, zero_count)
      }
  }
}

fn do_rotation_pt_1(position: Int, rotation: Rotation) {
  case rotation {
    Left(amount:) -> position - amount
    Right(amount:) -> position + amount
  }
  |> handle_overflow_pt_1
}

fn handle_overflow_pt_1(position) {
  case position {
    _ if position > 99 -> handle_overflow_pt_1(position - 100)
    _ if position < 0 -> handle_overflow_pt_1(position + 100)
    _ -> position
  }
}

pub fn pt_2(input: List(Rotation)) {
  list.fold(input, #(50, 0), fn(acc, rotation) {
    let #(position, zeros) = acc
    rotate(position, rotation, zeros)
  }).1
}

fn pt_2_loop(input: List(Rotation), position: Int, zero_count: Int) -> Int {
  case input {
    [] -> zero_count
    [rotation, ..rest] -> {
      let #(position, zeros) = do_rotation_pt_2(position, rotation)
      pt_2_loop(rest, position, zero_count + zeros)
    }
  }
}

fn rotate(from position: Int, by rotation: Rotation, zeros zeros: Int) {
  case rotation {
    Left(0) -> #(position, zeros)
    // we're at 0; roll over to 99
    Left(amount:) if position == 0 -> rotate(99, Left(amount - 1), zeros)
    // we're at 1; next one is 0
    Left(amount:) if position == 1 -> rotate(0, Left(amount - 1), zeros + 1)
    Left(amount:) -> rotate(position - 1, Left(amount - 1), zeros)

    Right(0) -> #(position, zeros)
    // we're at 99; roll over to 0
    Right(amount:) if position == 99 -> rotate(0, Right(amount - 1), zeros + 1)
    Right(amount:) -> rotate(position + 1, Right(amount - 1), zeros)
  }
}

fn do_rotation_pt_2(position: Int, rotation: Rotation) {
  case rotation {
    Left(amount:) -> position - amount
    Right(amount:) -> position + amount
  }
  |> handle_overflow_pt_2(0)
}

fn handle_overflow_pt_2(position, zero_count) {
  case position {
    _ if position > 99 -> handle_overflow_pt_2(position - 100, zero_count + 1)
    _ if position < 0 -> handle_overflow_pt_2(position + 100, zero_count + 1)
    _ -> #(position, zero_count)
  }
}
