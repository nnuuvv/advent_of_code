import gleam/bool
import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/string

pub type Position {
  Position(x: Int, y: Int, z: Int)
}

type Edge {
  Edge(length: Int, a: Position, b: Position)
}

fn equal_edge(edge_a, edge_b) {
  let Edge(_, a1, b1) = edge_a
  let Edge(_, a2, b2) = edge_b

  a1 == a2 && b1 == b2 || a1 == b2 && a2 == b1
}

fn connecting_edge(edge_a, edge_b) {
  let Edge(_, a1, b1) = edge_a
  let Edge(_, a2, b2) = edge_b

  a1 == a2 || b1 == b2 || a1 == b2 || b1 == a2
}

pub fn parse(input: String) {
  input
  |> string.split("\n")
  |> list.map(string.split(_, ","))
  |> list.map(fn(coords) {
    case coords {
      [x, y, z] -> {
        let assert Ok(x) = int.parse(x)
        let assert Ok(y) = int.parse(y)
        let assert Ok(z) = int.parse(z)
        Position(x:, y:, z:)
      }
      _ -> panic as "Invalid input"
    }
  })
}

pub fn pt_1(input: List(Position)) {
  let distances =
    input
    |> list.fold(dict.new(), fn(distances, point) {
      list.fold(input, distances, fn(distances, npoint) {
        let dist = distance_3d(point, npoint)
        dict.upsert(distances, point, fn(item) {
          case item {
            Some(item) -> [Edge(dist, point, npoint), ..item]
            _ -> [Edge(dist, point, npoint)]
          }
        })
      })
    })
    |> dict.map_values(fn(key, value) {
      list.filter(value, fn(item) { item.length != 0 })
    })

  let circuits = dict.new()
  pt_1_loop(distances, circuits, 1)
  // |> echo
  |> dict.values()
  |> list.map(fn(circuit) {
    list.fold(circuit, [], fn(acc, edge) {
      let is_in_acc =
        acc
        |> list.any(fn(in_acc) { equal_edge(in_acc, edge) })
      case is_in_acc {
        True -> acc
        False -> [edge, ..acc]
      }
    })
  })
  |> list.map(list.length)
  |> list.sort(int.compare)
  |> echo
  |> list.take(3)
  |> echo
  |> list.reduce(fn(a, b) { a * b })
  // todo as "part 1 not implemented"
}

fn pt_1_loop(
  distances: dict.Dict(Position, List(Edge)),
  circuits: dict.Dict(Int, List(Edge)),
  index_multi: Int,
) -> dict.Dict(Int, List(Edge)) {
  let distances =
    distances
    // filter out already assigned edges
    |> dict.map_values(fn(_, edges) {
      let circuits =
        circuits
        |> dict.values
        |> list.flatten

      edges
      |> list.filter(fn(edge) {
        circuits
        |> list.any(fn(in_circuit) { equal_edge(edge, in_circuit) })
        |> bool.negate()
      })
    })

  let remaining = distances |> dict.values() |> list.flatten() |> list.length()

  case remaining == 0 {
    True -> circuits
    False -> {
      pt_1_loop(
        distances,
        pt_1_loop_inner(distances, circuits, index_multi),
        index_multi * 10,
      )
    }
  }
}

fn pt_1_loop_inner(distances, circuits, index_multi) {
  distances
  |> dict.fold([], fn(smallest, _, distances) {
    let closest = closest(distances)
    [closest, ..smallest]
  })
  |> list.filter_map(fn(item) { item })
  // get shortest first
  |> list.sort(fn(a, b) { int.compare(a.length, b.length) })
  // make sure there are no self referencing edges
  |> list.filter(fn(a) { a.length != 0 })
  |> list.index_fold(circuits, fn(circuits, edge, index) {
    // are there any already existing circuits?
    let connected =
      dict.filter(circuits, fn(key, value) {
        list.any(value, fn(item) { connecting_edge(item, edge) })
      })

    let index = case connected |> dict.keys() {
      // yes? add to it
      [index, ..] -> index
      // no? add to current index
      _ -> index * index_multi
    }
    dict_append(circuits, index, edge)
  })
}

fn dict_append(dict, key, item) {
  dict.upsert(dict, key, fn(in_dict) {
    case in_dict {
      Some(in_dict) -> [item, ..in_dict] |> list.unique()
      None -> [item]
    }
  })
}

fn closest(distances: List(Edge)) {
  list.fold(distances, [], fn(smallest, item) {
    case smallest {
      [Edge(0, _, _)] | [] -> [item]
      [Edge(distance, _, _)] if distance > item.length -> [item]
      [Edge(distance, _, _)] if distance <= item.length -> smallest
      _ -> todo as "huh"
    }
  })
  |> list.first()
}

fn distance_3d(point_a, point_b) {
  let Position(x1, y1, z1) = point_a
  let Position(x2, y2, z2) = point_b

  let xdistance = dist_1d(x1, x2)
  let ydistance = dist_1d(y1, y2)
  let zdistance = dist_1d(z1, z2)

  xdistance + ydistance + zdistance
}

fn dist_1d(c1, c2) {
  let diff = c2 - c1
  let dist = diff * diff
  dist
}

pub fn pt_2(input: List(Position)) {
  todo as "part 2 not implemented"
}
