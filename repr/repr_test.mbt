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
  let p = Repr::prop("k", Repr::int(1))
  match Repr::with_children(p, []) {
    Prop("k", Omitted) => ()
    _ => fail("expected Prop(_, Omitted) fallback")
  }
  let ap = Repr::assoc_prop(Repr::string("k"), Repr::int(1))
  match Repr::with_children(ap, [Repr::int(0)]) {
    AssocProp(Omitted, Omitted) => ()
    _ => fail("expected AssocProp(Omitted, Omitted) fallback")
  }
}

///|
test "repr: record and assoc builders are structural" {
  let r = @repr.Repr::record({ "a": Repr::int(1), "b": Repr::bool(true) })
  match r {
    Record([Prop("a", IntLit(1)), Prop("b", BoolLit(true))]) => ()
    _ => fail("expected record to lower into Prop children")
  }
  let m = assoc([(Repr::string("a"), Repr::int(1))])
  match m {
    Assoc([AssocProp(StringLit("a"), IntLit(1))]) => ()
    _ => fail("expected assoc to lower into AssocProp children")
  }
}

///|
test "repr: traverse can hide fields" {
  let r : Repr = Repr::record({
    "user": Repr::string("alice"),
    "password": Repr::string("secret"),
  })
  let redacted = r.traverse(node => match node {
    Prop("password", _) => Repr::prop("password", Repr::omitted())
    _ => node
  })
  match redacted {
    Record([Prop("user", StringLit("alice")), Prop("password", Omitted)]) => ()
    _ => fail("expected traverse to omit password")
  }
}

///|
test "repr: to_json redaction" {
  let r : Repr = Repr::record({
    "user": Repr::string("alice"),
    "password": Repr::string("secret"),
  })
  let redacted = Repr::traverse(r, fn(node) {
    match node {
      Prop("password", _) => Repr::prop("password", Repr::omitted())
      _ => node
    }
  })
  match Repr::to_json(redacted) {
    Json::Object(map) => {
      match map.get("user") {
        Some(Json::String("alice")) => ()
        _ => fail("expected user to be \"alice\"")
      }
      match map.get("password") {
        Some(Json::Null) => ()
        _ => fail("expected password to be null")
      }
    }
    _ => fail("expected Json object")
  }
}

///|
test "repr: to_json ctor and opaque" {
  let r : Repr = Repr::ctor("Box", [
    Repr::arg("x", Repr::int(1)),
    Repr::string("y"),
  ])
  match Repr::to_json(r) {
    Json::Object(map) => {
      match map.get("$tag") {
        Some(Json::String("Box")) => ()
        _ => fail("expected $tag to be \"Box\"")
      }
      match map.get("$args") {
        Some(Json::Array(args)) =>
          match args {
            [Json::Object(arg0), Json::String("y")] => {
              match arg0.get("$label") {
                Some(Json::String("x")) => ()
                _ => fail("expected arg label to be \"x\"")
              }
              match arg0.get("$value") {
                Some(Json::Number(x, ..)) => assert_eq(x, 1.0)
                _ => fail("expected arg value to be number 1")
              }
            }
            _ => fail("expected two args")
          }
        _ => fail("expected $args array")
      }
    }
    _ => fail("expected Json object for ctor")
  }
  let o : Repr = Repr::opaque_node("Int64", [Repr::literal("123")])
  match Repr::to_json(o) {
    Json::Object(map) => {
      match map.get("$opaque") {
        Some(Json::String("Int64")) => ()
        _ => fail("expected $opaque to be \"Int64\"")
      }
      match map.get("$value") {
        Some(Json::Array([Json::String("123")])) => ()
        _ => fail("expected $value to contain literal")
      }
    }
    _ => fail("expected Json object for opaque")
  }
}

///|
test "repr: to_json assoc shapes" {
  let r = assoc([
    (Repr::string("a"), Repr::int(1)),
    (Repr::string("b"), Repr::bool(true)),
  ])
  @json.inspect(r.to_json(), content={ "a": 1, "b": true })
  let r = assoc([(Repr::int(1), Repr::bool(true))])
  let json = r.to_json()
  @json.inspect(json, content=[[1, true]])
}

///|
test "repr: to_json record stringify" {
  let r : Repr = Repr::record({ "a": Repr::int(1), "b": Repr::bool(true) })
  let s = Json::stringify(Repr::to_json(r), escape_slash=false)
  inspect(s, content="{\"a\":1,\"b\":true}")
}
