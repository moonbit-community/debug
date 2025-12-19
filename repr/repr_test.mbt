///|
test "repr: with_children preserves leaves" {
  let x = Repr::int(1)
  assert_eq(Repr::children(x).length(), 0)
  match Repr::with_children(x, [Repr::int(2)]) {
    IntLit(1) => ()
    _ => fail("expected leaf to ignore new children")
  }
}

///|
test "repr: with_children falls back for Prop and AssocProp" {
  let p = Repr::field("k", Repr::int(1))
  match Repr::with_children(p, []) {
    Field("k", Omitted) => ()
    _ => fail("expected Prop(_, Omitted) fallback")
  }
  let ap = Repr::entry(Repr::string("k"), Repr::int(1))
  match Repr::with_children(ap, [Repr::int(0)]) {
    Entry(Omitted, Omitted) => ()
    _ => fail("expected AssocProp(Omitted, Omitted) fallback")
  }
}

///|
test "repr: record and dict builders are structural" {
  let r = @repr.Repr::record({ "a": Repr::int(1), "b": Repr::bool(true) })
  match r {
    Record([Field("a", IntLit(1)), Field("b", BoolLit(true))]) => ()
    _ => fail("expected record to lower into Field children")
  }
  let m = Repr::dict([(Repr::string("a"), Repr::int(1))])
  match m {
    Dict([Entry(StringLit("a"), IntLit(1))]) => ()
    _ => fail("expected dict to lower into Entry children")
  }
}
