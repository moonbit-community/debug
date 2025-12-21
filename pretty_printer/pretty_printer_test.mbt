///|
test "pretty_printer: compact comma sequence" {
  let content = comma_seq("(", ")", [verbatim("a"), verbatim("b")])
  let rendered = print_content(content.compact().no_wrap())
  inspect(rendered, content="(a, b)")
}

///|
test "pretty_printer: surround and indent" {
  let inner = comma_seq("", "", [verbatim("x"), verbatim("y")])
  let wrapped = surround("{ ", " }", indent("  ", inner.no_wrap()))
  inspect(
    print_content(wrapped),
    content=(
      #|{   x,
      #|  y }
    ),
  )
}

///|
test "pretty_printer: parens metadata" {
  let r = parens(verbatim("..."))
  inspect(r.needs_parens, content="true")
}
