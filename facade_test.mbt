///|
fn opts_no_ansi() -> @pp.PrettyPrintOptions {
  pretty_print_options(max_depth=None, compact_threshold=100, use_ansi=false)
}

///|
test "facade: Repr constructors pretty-print as expected" {
  let opts = opts_no_ansi()
  inspect(pretty_print_repr_with(opts, Repr::int(42)), content="42")
  inspect(pretty_print_repr_with(opts, Repr::double(1.5)), content="1.5")
  inspect(pretty_print_repr_with(opts, Repr::bool(true)), content="true")
  inspect(pretty_print_repr_with(opts, Repr::char('x')), content="'x'")
  inspect(pretty_print_repr_with(opts, Repr::string("hi")), content="\"hi\"")
  inspect(pretty_print_repr_with(opts, unit()), content="()")
  inspect(
    pretty_print_repr_with(opts, Repr::tuple([Repr::int(1), Repr::string("x")])),
    content="(1, \"x\")",
  )
  inspect(
    pretty_print_repr_with(opts, Repr::array([Repr::int(1), Repr::int(2)])),
    content="[ 1, 2 ]",
  )
  inspect(
    pretty_print_repr_with(
      opts,
      Repr::record({ "a": Repr::int(1), "b": Repr::int(2) }),
    ),
    content="{ a: 1, b: 2 }",
  )
  inspect(
    pretty_print_repr_with(opts, ctor("Ok", [Repr::string("yes")])),
    content="Ok(\"yes\")",
  )
  inspect(
    pretty_print_repr_with(
      opts,
      ctor("A", [arg("x", Repr::int(1)), arg("y", Repr::string("yes"))]),
    ),
    content="A(x=1, y=\"yes\")",
  )
  inspect(
    pretty_print_repr_with(
      opts,
      ctor("B", [arg("x", Repr::int(1)), Repr::string("s")]),
    ),
    content="B(x=1, \"s\")",
  )
  inspect(
    pretty_print_repr_with(opts, opaque_("function")),
    content="<function>",
  )
  inspect(
    pretty_print_repr_with(opts, opaque_literal("Int64", "1")),
    content="<Int64: 1>",
  )
  inspect(
    pretty_print_repr_with(
      opts,
      collection("Vec", [Repr::int(1), Repr::int(2)]),
    ),
    content="<Vec: [ 1, 2 ]>",
  )
  inspect(
    pretty_print_repr_with(
      opts,
      Repr::dict([(Repr::string("a"), Repr::int(1))]),
    ),
    content="{ \"a\": 1 }",
  )
}

///|
test "facade: diff + pretty_print_delta wrappers round-trip" {
  let opts = opts_no_ansi()
  let x = Repr::record({ "a": Repr::int(1) })
  let y = Repr::record({ "a": Repr::int(2) })
  let d = diff_repr(x, y)
  inspect(pretty_print_delta_with(opts, d), content="{ a: -1 +2 }")
}

///|
test "instances: option None and numeric wrappers have repr" {
  inspect(pretty_print((None : Int?)), content="None")
  let i64 : Int64 = 1
  let u : UInt = 2
  inspect(pretty_print(i64), content="<Int64: 1>")
  inspect(pretty_print(u), content="<UInt: 2>")
}
