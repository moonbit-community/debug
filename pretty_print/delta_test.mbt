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
test "prune: does not count RecordField as depth" {
  let r = @repr.Repr::record({
    "x": @repr.Repr::ctor("A", [
      (None, @repr.Repr::ctor("B", [(None, @repr.Repr::int(1))])),
    ]),
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

///|
test "pretty print: Fixnum (various integer types)" {
  // Int16
  let int16_pos = @repr.Repr::int16(42)
  let int16_neg = @repr.Repr::int16(-42)
  inspect(pretty_print_repr_with(print_opts(), int16_pos), content="42")
  inspect(pretty_print_repr_with(print_opts(), int16_neg), content="-42")
  // Int
  let int_pos = @repr.Repr::int(42)
  let int_neg = @repr.Repr::int(-42)
  inspect(pretty_print_repr_with(print_opts(), int_pos), content="42")
  inspect(pretty_print_repr_with(print_opts(), int_neg), content="-42")
  // Int64
  let int64_pos = @repr.Repr::int64(1000L)
  let int64_neg = @repr.Repr::int64(-1000L)
  inspect(pretty_print_repr_with(print_opts(), int64_pos), content="1000L")
  inspect(pretty_print_repr_with(print_opts(), int64_neg), content="-1000L")
  // UInt16
  let uint16 = @repr.Repr::uint16(14)
  inspect(pretty_print_repr_with(print_opts(), uint16), content="14")
  // UInt
  let uint = @repr.Repr::uint(14U)
  inspect(pretty_print_repr_with(print_opts(), uint), content="14U")
  // UInt64
  let uint64 = @repr.Repr::uint64(14UL)
  inspect(pretty_print_repr_with(print_opts(), uint64), content="14UL")
}

///|
test "pretty print: FloatLit" {
  let pos : Float = 3.14
  let neg : Float = -3.14
  inspect(
    pretty_print_repr_with(print_opts(), @repr.Repr::float(pos)),
    content="3.140000104904175",
  )
  inspect(
    pretty_print_repr_with(print_opts(), @repr.Repr::float(neg)),
    content="-3.140000104904175",
  )
}
