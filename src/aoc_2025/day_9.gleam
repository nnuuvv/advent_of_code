import gleam/float
import gleam/int
import gleam/list
import gleam/set
import gleam/string

pub fn parse(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [x, y] = string.split(line, ",")
    let assert Ok(x) = int.parse(x)
    let assert Ok(y) = int.parse(y)
    Point(x:, y:)
  })
}

pub type Point {
  Point(x: Int, y: Int)
}

pub type FloatPoint {
  FloatPoint(x: Float, y: Float)
}

pub type Area {
  Area(a: Point, b: Point, area: Int)
}

pub type Area4Point {
  Area4Point(
    a: FloatPoint,
    b: FloatPoint,
    c: FloatPoint,
    d: FloatPoint,
    area: Float,
  )
}

pub fn pt_1(input: List(Point)) {
  input
  |> list.fold(set.new(), fn(areas, point_a) {
    input
    |> list.fold(areas, fn(areas, point_b) {
      let area =
        { int.absolute_value(point_a.x - point_b.x) + 1 }
        * { int.absolute_value(point_a.y - point_b.y) + 1 }

      areas
      |> set.insert(Area(point_a, point_b, area))
    })
  })
  |> set.fold(0, fn(acc, area) {
    case area {
      Area(a:, b:, area:) if area > acc -> area
      _ -> acc
    }
  })
}

pub fn pt_2(input: List(Point)) {
  // echo intersect(#(Point(0, 0), Point(10, 10)), #(Point(0, 5), Point(0, 2)))

  // let mid_x = { largest_x - smallest_x } / 2
  // |> echo
  // let mid_y = { largest_y - smallest_y } / 2
  // |> echo

  let input =
    input
    |> list.map(fn(point) {
      FloatPoint(int.to_float(point.x), int.to_float(point.y))
    })

  input
  |> list.fold(set.new(), fn(acc, point_a) {
    input
    |> list.fold(acc, fn(acc, point_b) {
      case point_a, point_b {
        point_a, point_b if point_a == point_b -> acc

        _, _ -> acc |> set.insert(other_corners(point_a, point_b))
      }
    })
  })
  |> set.filter(fn(area) {
    let Area4Point(_, _, c, d, _) = area
    let assert Ok(first) = list.first(input)

    let input = list.append(input, [first])

    // case a {
    //   FloatPoint(x:, y:) if x == 11.0 && y == 1.0 && area.area == 50.0 -> {
    //     echo area
    //     echo count_intersections(of: c, in: input, acc: 0) as "c"
    //     echo count_intersections(of: d, in: input, acc: 0) as "d"
    //     Nil
    //   }
    //   _ -> Nil
    // }

    count_intersections(of: c, in: input, acc: 0) |> int.is_odd()
    && count_intersections(of: d, in: input, acc: 0) |> int.is_odd()
    // #(
    //   area,
    //   count_intersections(of: c, in: input, acc: 0),
    //   count_intersections(of: d, in: input, acc: 0),
    // )
    // False
  })
  |> echo
  |> set.fold(0.0, fn(acc, area) {
    case area {
      Area4Point(a: _, b: _, c: _, d: _, area:) if area >. acc -> area
      _ -> acc
    }
  })
  // |> echo
}

fn count_intersections(
  of intersecting_point: FloatPoint,
  in all_points: List(FloatPoint),
  acc sum: Int,
) {
  case all_points {
    [] | [_] -> sum
    [a, b, ..rest] -> {
      case a {
        a if a == intersecting_point -> 1
        _ -> {
          case
            intersect(
              line: #(FloatPoint(0.0, 0.0), intersecting_point),
              on_line: #(a, b),
            )
          {
            True -> {
              // echo string.inspect(a) <> " | " <> string.inspect(b) as "a-b, true"
              count_intersections(intersecting_point, [b, ..rest], sum + 1)
            }
            False -> count_intersections(intersecting_point, [b, ..rest], sum)
          }
        }
      }
    }

    s -> {
      echo s
      panic as "huh"
    }
  }
}

fn other_corners(point_a: FloatPoint, point_b: FloatPoint) {
  let area =
    { float.absolute_value(point_a.x -. point_b.x) +. 1.0 }
    *. { float.absolute_value(point_a.y -. point_b.y) +. 1.0 }

  Area4Point(
    point_a,
    point_b,
    FloatPoint(point_a.x, point_b.y),
    FloatPoint(point_b.x, point_a.y),
    area,
  )
}

fn intersect(
  line line_a: #(FloatPoint, FloatPoint),
  on_line line_b: #(FloatPoint, FloatPoint),
) {
  let #(FloatPoint(x1, y1), FloatPoint(x2, y2)) = line_a
  let #(FloatPoint(x3, y3), FloatPoint(x4, y4)) = line_b

  let denominator = { x1 -. x2 } *. { y3 -. y4 } -. { y1 -. y2 } *. { x3 -. x4 }

  case denominator {
    0.0 -> False
    _ -> {
      let px =
        {
          { x1 *. y2 -. y1 *. x2 }
          *. { x3 -. x4 }
          -. { x1 -. x2 }
          *. { x3 *. y4 -. y3 *. x4 }
        }
        /. denominator

      let py =
        {
          { x1 *. y2 -. y1 *. x2 }
          *. { y3 -. y4 }
          -. { y1 -. y2 }
          *. { x3 *. y4 -. y3 *. x4 }
        }
        /. denominator

      echo string.inspect(line_a)
        <> " intersects "
        <> string.inspect(line_b)
        <> " at "
        <> string.inspect(FloatPoint(px, py))
        <> " on line_b?: "
        <> string.inspect(on_line(line_b, FloatPoint(px, py)))

      on_line(line_b, FloatPoint(px, py))
    }
  }
}

fn on_line(line: #(FloatPoint, FloatPoint), point: FloatPoint) {
  case line {
    #(a, b)
      if {
        a.x >=. point.x
        && b.x <=. point.x
        && a.y >=. point.y
        && b.y <=. point.y
      }
      || {
        a.x >=. point.x
        && b.x <=. point.x
        && a.y <=. point.y
        && b.y >=. point.y
      }
      || {
        a.x <=. point.x
        && b.x >=. point.x
        && a.y >=. point.y
        && b.y <=. point.y
      }
      || {
        a.x <=. point.x
        && b.x >=. point.x
        && a.y <=. point.y
        && b.y >=. point.y
      }
    -> True
    _ -> False
  }
}
