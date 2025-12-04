import aoc_2025/day_3
import gleam/int
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
