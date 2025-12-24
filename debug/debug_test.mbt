///|
using @repr {type Repr}

///|
test "pretty_print repr for map" {
  let items : Array[(String, Int)] = [("a", 3), ("b", 6), ("c", 13)]
  let x : Map[String, Int] = Map::from_array(items[:])
  inspect(
    pretty_print(x),
    content=(
      #|{ "a": 3, "b": 6, "c": 13 }
    ),
  )
}

///|
test "pretty_print delta for map (no ansi)" {
  let items : Array[(String, Int)] = [("a", 3), ("b", 6), ("c", 13)]
  let x : Map[String, Int] = Map::from_array(items[:])
  let y : Map[String, Int] = Map::from_array((items + [("b", 9)])[:])
  inspect(
    pretty_print_diff(x, y, max_depth=6, compact_threshold=40, use_ansi=false),
    content=(
      #|{ "a": 3, "b": -6 +9, "c": 13 }
    ),
  )
}

///|
test "opaque types have a repr" {
  let r = Repr::opaque_("function", [])
  inspect(pretty_print_repr(r), content="<function>")
  inspect(pretty_print_delta(diff_repr(r, r)), content="<function>")
}

///|
test "debug_trait: diff uses explicit options" {
  let x : Double = 1.0
  let y : Double = 1.0 + 1.0e-13
  match diff(x, y, max_relative_error=0.0).delta() {
    Different(_, _) => ()
    _ => fail("expected strict diff to be Different")
  }
  match diff(x, y, max_relative_error=1.0e-12).delta() {
    Same(DoubleLit(_), []) => ()
    _ => fail("expected tolerant diff to be Same")
  }
}

///|
test "debug_trait: pretty_print_diff uses default options" {
  inspect(pretty_print_diff(1, 1), content="1")
  inspect(
    pretty_print_diff(1, 2),
    content="\u001b[31m-1\u001b[0m \u001b[32m+2\u001b[0m",
  )
}
