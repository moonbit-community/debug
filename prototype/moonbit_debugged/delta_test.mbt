///|
fn print_opts() -> PrettyPrintOptions {
  { max_depth: None, compact_threshold: 100, use_ansi: false }
}

///|
test "diff: arrays collapse when all children differ" {
  let x : Repr = array([int(1), int(2)])
  let y : Repr = array([int(3), int(4)])
  inspect(
    pretty_print_delta_with(print_opts(), diff_repr(x, y)),
    content="-[ 1, 2 ] +[ 3, 4 ]",
  )
}

///|
test "diff: arrays show per-element when some children same" {
  let x : Repr = array([int(1), int(2)])
  let y : Repr = array([int(1), int(3)])
  inspect(
    pretty_print_delta_with(print_opts(), diff_repr(x, y)),
    content="[ 1, -2 +3 ]",
  )
}

///|
test "diff: record field changes keep field name" {
  let x : Repr = record([("a", int(1)), ("b", int(2))])
  let y : Repr = record([("a", int(9)), ("b", int(2))])
  inspect(
    pretty_print_delta_with(print_opts(), diff_repr(x, y)),
    content="{ a: -1 +9, b: 2 }",
  )
}

///|
test "pretty_print: prune does not count Prop as depth" {
  let r : Repr = record([("x", ctor("A", [ctor("B", [int(1)])]))])
  let opts : PrettyPrintOptions = {
    max_depth: Some(2),
    compact_threshold: 100,
    use_ansi: false,
  }
  inspect(pretty_print_repr_with(opts, r), content="{ x: A (...) }")
}

///|
test "diff: assoc prop renders `k: v`" {
  let x : Repr = assoc("Map", [(string("a"), int(1))])
  let y : Repr = assoc("Map", [(string("a"), int(2))])
  inspect(
    pretty_print_delta_with(print_opts(), diff_repr(x, y)),
    content="<Map: { \"a\": -1 +2 }>",
  )
}
