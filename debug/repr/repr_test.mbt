///|
test "repr: with_children preserves leaves" {
  let x = @repr.Repr::int(1)
  assert_eq(x.children().length(), 0)
  match x.with_children([@repr.Repr::int(2)]) {
    Fixnum("1") => ()
    _ => fail("expected leaf to ignore new children")
  }
}

///|
test "repr: record and dict builders are structural" {
  let r = @repr.Repr::record({
    "a": @repr.Repr::int(1),
    "b": @repr.Repr::bool(true),
  })
  match r {
    Record([RecordField("a", Fixnum("1")), RecordField("b", BoolLit(true))]) =>
      ()
    _ => fail("expected record to lower into RecordField children")
  }
  let m = @repr.Repr::dict([(@repr.Repr::string("a"), @repr.Repr::int(1))])
  match m {
    Map([MapEntry(StringLit("a"), Fixnum("1"))]) => ()
    _ => fail("expected dict to lower into MapEntry children")
  }
}

///|
test "repr: ctor lowers labeled args" {
  let r = @repr.Repr::ctor("A", [
    (Some("x"), @repr.Repr::int(1)),
    (None, @repr.Repr::string("s")),
  ])
  match r {
    Enum("A", [EnumLabeledArg("x", Fixnum("1")), StringLit("s")]) => ()
    _ => fail("expected ctor to lower labeled args")
  }
}

///|
test "repr: traverse can hide fields" {
  let r : @repr.Repr = @repr.Repr::record({
    "user": @repr.Repr::string("alice"),
    "password": @repr.Repr::string("secret"),
  })
  let redacted = r.traverse(fn(node) {
    match node {
      RecordField("password", _) => node.with_children([@repr.Repr::omitted()])
      _ => node
    }
  })
  match redacted {
    Record(
      [
        RecordField("user", StringLit("alice")),
        RecordField("password", Omitted),
      ]
    ) => ()
    _ => fail("expected traverse to omit password")
  }
}
