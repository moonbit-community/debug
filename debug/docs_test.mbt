///|
test "docs: pretty_print for option and tuple" {
  inspect(@debug.pretty_print(()), content="()")
  inspect(@debug.pretty_print(Some(1)), content="Some(1)")
  inspect(@debug.pretty_print((1, "x")), content="(1, \"x\")")
}
