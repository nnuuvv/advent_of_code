import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/result
import gleam/string

pub type Problem {
  Problem(numbers: List(Int), operator: Operator)
}

fn new_problem() {
  Problem([], Unset)
}

pub type Operator {
  Unset
  Plus
  Multiply
}

pub fn pt_1(input: String) {
  input
  // get rows
  |> string.split("\n")
  // split by space
  |> list.map(string.split(_, " "))
  // drop back to back whitespaces
  |> list.map(list.filter(_, fn(item) { item != "" }))
  |> list.interleave()
  // parse list of "int, int, int, operator, int, int, int, operator" into Problem(List(Int), Operator)
  |> list.fold(#([], new_problem()), fn(acc, cur_item) {
    let #(parsed_problems, Problem(numbers:, operator:)) = acc
    case cur_item {
      // empty item
      "" -> acc
      // problem finished
      "*" -> #([Problem(numbers, Multiply), ..parsed_problems], new_problem())
      "+" -> #([Problem(numbers, Plus), ..parsed_problems], new_problem())
      // number
      number -> {
        let assert Ok(number) = int.parse(number) as "invalid input"
        #(parsed_problems, Problem([number, ..numbers], operator))
      }
    }
  })
  |> pair.first()
  |> solve_problems()
}

pub fn pt_2(input: String) {
  let row =
    input
    // get rows
    |> string.split("\n")

  let assert [first_row, ..] = row

  let grapheme_rows =
    row
    |> list.flat_map(string.to_graphemes)
    |> list.sized_chunk(string.length(first_row))

  let assert Ok(operator_row) = list.last(grapheme_rows) as "invalid input"

  let problem_count =
    operator_row
    |> list.filter(fn(item) { item != " " })
    |> list.length()

  // echo first_row as "first_row"

  let interleaved =
    grapheme_rows
    // |> echo
    |> list.interleave()
  let row_count = list.length(grapheme_rows)

  let problems =
    parse_problems_by_column(interleaved, row_count, new_problem(), [])
  // |> echo

  echo list.length(problems) as "problems"
  echo problem_count as "problem_count"

  problems
  |> solve_problems()
}

/// parses problems one column at a time
fn parse_problems_by_column(
  chars: List(String),
  row_count: Int,
  current_problem,
  problems,
) {
  let column =
    chars
    |> list.take(row_count)

  let column_unique = list.unique(column)

  case column {
    [] -> [current_problem, ..problems]
    // fully empty column
    _ if column_unique == [" "] ->
      parse_problems_by_column(
        list.drop(chars, row_count),
        row_count,
        new_problem(),
        [current_problem, ..problems],
      )
    column -> {
      let current_problem = case parse_column(column, 0) {
        #(number, Some(operator)) ->
          Problem([number, ..current_problem.numbers], operator)

        #(number, None) ->
          Problem([number, ..current_problem.numbers], current_problem.operator)
      }

      parse_problems_by_column(
        list.drop(chars, row_count),
        row_count,
        current_problem,
        problems,
      )
    }
  }
}

/// parsed one column worth of data
fn parse_column(column_chars: List(String), number) {
  case column_chars {
    // last char
    [" "] -> #(number, None)
    ["*"] -> #(number, Some(Multiply))
    ["+"] -> #(number, Some(Plus))
    // drop leading whitespace
    [" ", ..rest] -> parse_column(rest, number)
    // number
    [num, ..rest]
      if num == "0"
      || num == "1"
      || num == "2"
      || num == "3"
      || num == "4"
      || num == "5"
      || num == "6"
      || num == "7"
      || num == "8"
      || num == "9"
    -> {
      let assert Ok(num) = int.parse(num)
      parse_column(rest, number * 10 + num)
    }
    _ -> panic as "shouldn't happen"
  }
}

fn solve_problems(problems: List(Problem)) -> Int {
  problems
  |> list.fold(0, fn(acc, problem) {
    // echo problem

    let assert Ok(result) = case problem {
      Problem(numbers: _, operator: Unset) -> panic as "welp"

      Problem(numbers:, operator: Plus) -> {
        list.reduce(numbers, int.add)
      }
      Problem(numbers:, operator: Multiply) ->
        list.reduce(numbers, int.multiply)
    }
    result + acc
  })
}
