///|
test "docs: pretty_print for option and tuple" {
  inspect(pretty_print(Some(1)), content="Some 1")
  inspect(pretty_print((1, "x")), content="Tuple 1 \"x\"")
}

///|
test "docs: building Repr manually" {
  let r : Repr = record([
    ("answer", int(42)),
    ("xs", array([int(1), int(2), int(3)])),
    ("tag", ctor("Ok", [string("done")])),
  ])
  inspect(
    pretty_print_repr_with(
      { max_depth: None, compact_threshold: 100, use_ansi: false },
      r,
    ),
    content="{ answer: 42, xs: [ 1, 2, 3 ], tag: Ok \"done\" }",
  )
}

///|
test "docs: record keys are quoted when needed" {
  let r : Repr = record([
    ("snake_case_ok", int(1)),
    ("with space", int(2)),
    ("k-v", int(3)),
    ("CamelCase", int(4)),
  ])
  inspect(
    pretty_print_repr_with(
      { max_depth: None, compact_threshold: 100, use_ansi: false },
      r,
    ),
    content="{ snake_case_ok: 1, \"with space\": 2, \"k-v\": 3, \"CamelCase\": 4 }",
  )
}

///|
test "docs: compact_threshold controls single-line vs multi-line" {
  let xs : Array[Int] = [1, 2, 3]
  let compact : String = pretty_print(xs)
  let expanded : String = pretty_print_with(
    { max_depth: None, compact_threshold: 0, use_ansi: false },
    xs,
  )
  inspect(compact, content="[ 1, 2, 3 ]")
  inspect(
    expanded,
    content=(
      #|[ 1,
      #|  2,
      #|  3 ]
    ),
  )
}

///|
test "docs: diff_with can ignore tiny float changes" {
  let print_opts : PrettyPrintOptions = {
    max_depth: None,
    compact_threshold: 100,
    use_ansi: false,
  }
  let strict : DiffOptions = { max_relative_error: 0.0 }
  let tolerant : DiffOptions = { max_relative_error: 1.0e-12 }
  inspect(
    (
      pretty_print_delta_with(print_opts, diff_with(strict, 1.0, 1.0 + 1.0e-13)),
      pretty_print_delta_with(
        print_opts,
        diff_with(tolerant, 1.0, 1.0 + 1.0e-13),
      ),
    ),
    content="(\"-1 +1.0000000000001\", \"1\")",
  )
}
