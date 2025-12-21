///|
test "pretty_printer: empty_content prints empty" {
  inspect(
    @printer.print_content(@printer.empty_content().no_wrap()),
    content="",
  )
}

///|
test "pretty_printer: surround_lines handles empty and singleton" {
  let empty = @printer.surround("(", ")", @printer.verbatim(""))
  inspect(@printer.print_content(empty), content="()")
  let single = @printer.surround("(", ")", @printer.verbatim("x"))
  inspect(@printer.print_content(single), content="(x)")
}

///|
test "pretty_printer: compact_lines handles empty and multiline" {
  let content = @printer.comma_seq("", "", [
    @printer.verbatim("a"),
    @printer.verbatim("b"),
    @printer.verbatim("c"),
  ])
  let compact = content.compact()
  inspect(@printer.print_content(compact.no_wrap()), content="a, b, c")
}

///|
test "pretty_printer: comma_seq_lines filters empty lines" {
  let empty = @printer.comma_seq("", "", [])
  inspect(@printer.print_content(empty.no_wrap()), content="")
}
