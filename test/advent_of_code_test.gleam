import aoc_2025/day_3
import aoc_2025/day_5
import gleam/int
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn day_3_part_2_test() {
  let bank =
    day_3.BatteryBank([
      //
      4, 3, 2, 1,
      //
      4, 3, 2, 1,
      //
      4, 3, 2, 1,
      //
      4, 3, 2, 1,
      //
      4, 3, 2, 1,
      //
      4, 3, 2, 1,
      //
      4, 3, 2, 1,
      //
      4, 3, 2, 1,
      //
      4, 3, 2, 1,
      //
      4, 3, 2, 1,
      //
      4, 3, 2, 1,
      //
      4, 3, 2, 1,
    ])

  let answer = day_3.pt_2([bank])
  should.equal(answer, 444_444_444_444)
}

pub fn day_5_pt_2_icky_test() {
  [
    // overlap right
    [#(1, 5), #(3, 7)],
    // fully fits
    [#(3, 5), #(1, 7)],
    [#(1, 7), #(3, 5)],
    // overlap left
    [#(3, 7), #(1, 5)],

    [#(1, 3), #(5, 7), #(2, 6)],

    [#(1, 3), #(5, 7), #(2, 6)],
    [#(1, 3), #(4, 4), #(5, 7)],
  ]
  |> list.map(fn(in) {
    echo in
    assert day_5.pt_2(#(in, [])) == 7
  })
}
