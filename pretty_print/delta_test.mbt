///|
test "diff printing: arrays collapse when all children differ" {
  let x = @repr.Repr::array([@repr.Repr::int(1), @repr.Repr::int(2)])
  let y = @repr.Repr::array([@repr.Repr::int(3), @repr.Repr::int(4)])
  inspect(
    pretty_print_delta_with(print_opts(), @diff.diff_repr(x, y)),
    content="-[ 1, 2 ] +[ 3, 4 ]",
  )
}

///|
test "diff printing: arrays show per-element when some children same" {
  let x = @repr.Repr::array([@repr.Repr::int(1), @repr.Repr::int(2)])
  let y = @repr.Repr::array([@repr.Repr::int(1), @repr.Repr::int(3)])
  inspect(
    pretty_print_delta_with(print_opts(), @diff.diff_repr(x, y)),
    content="[ 1, -2 +3 ]",
  )
}

///|
test "diff printing: record field changes keep field name" {
  let x = @repr.Repr::record({
    "a": @repr.Repr::int(1),
    "b": @repr.Repr::int(2),
  })
  let y = @repr.Repr::record({
    "a": @repr.Repr::int(9),
    "b": @repr.Repr::int(2),
  })
  inspect(
    pretty_print_delta_with(print_opts(), @diff.diff_repr(x, y)),
    content="{ a: -1 +9, b: 2 }",
  )
}

///|
test "prune: does not count Prop as depth" {
  let r = @repr.Repr::record({
    "x": @repr.ctor("A", [@repr.ctor("B", [@repr.Repr::int(1)])]),
  })
  let opts : PrettyPrintOptions = {
    max_depth: Some(2),
    compact_threshold: 100,
    use_ansi: false,
  }
  inspect(pretty_print_repr_with(opts, r), content="{ x: A(...) }")
}

///|
test "dict entry prints `k: v`" {
  let x = @repr.Repr::dict([(@repr.Repr::string("a"), @repr.Repr::int(1))])
  let y = @repr.Repr::dict([(@repr.Repr::string("a"), @repr.Repr::int(2))])
  inspect(
    pretty_print_delta_with(print_opts(), @diff.diff_repr(x, y)),
    content="{ \"a\": -1 +2 }",
  )
}
