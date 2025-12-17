///|
/// Direct structural representation for debugging/diffing/pretty-printing.
pub(all) enum DebugInfo {
  IntLit(Int)
  DoubleLit(Double)
  BoolLit(Bool)
  CharLit(Char)
  StringLit(String)
  Array(Array[DebugInfo])
  Record(Array[DebugInfo])
  Prop(String, DebugInfo)
  Ctor(String, Array[DebugInfo])
  Opaque(String, Array[DebugInfo])
  Literal(String)
  Assoc(String, Array[DebugInfo])
  AssocProp(DebugInfo, DebugInfo)
  Omitted
} derive(Eq, Compare)

///|
/// Structural representation for debugging/diffing.
pub struct Repr(DebugInfo) derive(Eq, Compare)

///|
/// Extract the underlying structure from a `Repr`.
pub fn Repr::info(self : Repr) -> DebugInfo {
  self.0
}

///|
/// Construct a `Repr` from a raw `DebugInfo`.
pub fn Repr::from_info(info : DebugInfo) -> Repr {
  Repr(info)
}

///|
/// Construct an integer `Repr`.
pub fn int(x : Int) -> Repr {
  Repr::from_info(IntLit(x))
}

///|
/// Construct a double `Repr`.
pub fn double(x : Double) -> Repr {
  Repr::from_info(DoubleLit(x))
}

///|
/// Construct a boolean `Repr`.
pub fn bool(x : Bool) -> Repr {
  Repr::from_info(BoolLit(x))
}

///|
/// Construct a char `Repr`.
pub fn char(x : Char) -> Repr {
  Repr::from_info(CharLit(x))
}

///|
/// Construct a string `Repr`.
pub fn string(x : String) -> Repr {
  Repr::from_info(StringLit(x))
}

///|
/// Construct an array `Repr` from pre-built child `Repr`s.
pub fn array(xs : Array[Repr]) -> Repr {
  Repr::from_info(Array(xs.map(fn(r) { Repr::info(r) })))
}

///|
/// Convert record field pairs into property nodes.
fn make_props(fields : Array[(String, Repr)]) -> Array[DebugInfo] {
  fields.map(fn(field) {
    let (name, value) = field
    Prop(name, Repr::info(value))
  })
}

///|
/// Construct a record `Repr` from field name/value pairs.
pub fn record(fields : Array[(String, Repr)]) -> Repr {
  Repr::from_info(Record(make_props(fields)))
}

///|
/// Construct a constructor/application `Repr` with a name and argument list.
pub fn ctor(name : String, args : Array[Repr]) -> Repr {
  Repr::from_info(Ctor(name, args.map(fn(r) { Repr::info(r) })))
}

///|
/// Construct an opaque wrapper `Repr` with a single child.
pub fn opaque_child(name : String, child : Repr) -> Repr {
  Repr::from_info(Opaque(name, [Repr::info(child)]))
}

///|
/// Construct an opaque wrapper `Repr` with no children.
pub fn opaque_(name : String) -> Repr {
  Repr::from_info(Opaque(name, []))
}

///|
/// Construct an opaque wrapper `Repr` containing a literal leaf (already formatted).
pub fn opaque_literal(name : String, value : String) -> Repr {
  Repr::from_info(Opaque(name, [Literal(value)]))
}

///|
/// Convenience helper for “collection-like” reprs: `<name: [ ... ]>`.
pub fn collection(name : String, contents : Array[Repr]) -> Repr {
  opaque_child(name, array(contents))
}

///|
/// Construct an association/kv `Repr` from key/value `Repr` pairs.
pub fn assoc(name : String, contents : Array[(Repr, Repr)]) -> Repr {
  Repr::from_info(
    Assoc(
      name,
      contents.map(fn(pair) {
        let (k, v) = pair
        AssocProp(Repr::info(k), Repr::info(v))
      }),
    ),
  )
}
