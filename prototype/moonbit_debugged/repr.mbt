///|
/// Direct structural representation for debugging/diffing/pretty-printing.
enum DebugInfo {
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
fn un_repr(r : Repr) -> DebugInfo {
  r.0
}

///|
/// Construct an integer `Repr`.
pub fn int(x : Int) -> Repr {
  Repr(IntLit(x))
}

///|
/// Construct a double `Repr`.
pub fn double(x : Double) -> Repr {
  Repr(DoubleLit(x))
}

///|
/// Construct a boolean `Repr`.
pub fn bool(x : Bool) -> Repr {
  Repr(BoolLit(x))
}

///|
/// Construct a char `Repr`.
pub fn char(x : Char) -> Repr {
  Repr(CharLit(x))
}

///|
/// Construct a string `Repr`.
pub fn string(x : String) -> Repr {
  Repr(StringLit(x))
}

///|
/// Construct an array `Repr` from pre-built child `Repr`s.
pub fn array(xs : Array[Repr]) -> Repr {
  Repr(Array(xs.map(fn(r) { un_repr(r) })))
}

///|
/// Convert record field pairs into property nodes.
fn make_props(fields : Array[(String, Repr)]) -> Array[DebugInfo] {
  fields.map(fn(field) {
    let (name, value) = field
    Prop(name, un_repr(value))
  })
}

///|
/// Construct a record `Repr` from field name/value pairs.
pub fn record(fields : Array[(String, Repr)]) -> Repr {
  Repr(Record(make_props(fields)))
}

///|
/// Construct a constructor/application `Repr` with a name and argument list.
pub fn ctor(name : String, args : Array[Repr]) -> Repr {
  Repr(Ctor(name, args.map(fn(r) { un_repr(r) })))
}

///|
/// Construct an opaque wrapper `Repr` with a single child.
pub fn opaque_child(name : String, child : Repr) -> Repr {
  Repr(Opaque(name, [un_repr(child)]))
}

///|
/// Construct an opaque wrapper `Repr` with no children.
pub fn opaque_(name : String) -> Repr {
  Repr(Opaque(name, []))
}

///|
/// Construct an opaque wrapper `Repr` containing a literal leaf (already formatted).
pub fn opaque_literal(name : String, value : String) -> Repr {
  Repr(Opaque(name, [Literal(value)]))
}

///|
/// Convenience helper for “collection-like” reprs: `<name: [ ... ]>`.
pub fn collection(name : String, contents : Array[Repr]) -> Repr {
  opaque_child(name, array(contents))
}

///|
/// Construct an association/kv `Repr` from key/value `Repr` pairs.
pub fn assoc(name : String, contents : Array[(Repr, Repr)]) -> Repr {
  Repr(
    Assoc(
      name,
      contents.map(fn(pair) {
        let (k, v) = pair
        AssocProp(un_repr(k), un_repr(v))
      }),
    ),
  )
}

///|
/// Child nodes of a `DebugInfo` node.
fn debug_info_children(info : DebugInfo) -> Array[DebugInfo] {
  match info {
    IntLit(_)
    | DoubleLit(_)
    | BoolLit(_)
    | CharLit(_)
    | StringLit(_)
    | Literal(_)
    | Omitted => []
    Array(xs) | Record(xs) | Ctor(_, xs) | Opaque(_, xs) | Assoc(_, xs) => xs
    Prop(_, value) => [value]
    AssocProp(key, value) => [key, value]
  }
}

///|
/// Rebuild a `DebugInfo` node with a new child list (payload is preserved).
fn debug_info_with_children(
  info : DebugInfo,
  children : Array[DebugInfo],
) -> DebugInfo {
  match info {
    IntLit(_)
    | DoubleLit(_)
    | BoolLit(_)
    | CharLit(_)
    | StringLit(_)
    | Literal(_)
    | Omitted => info
    Array(_) => Array(children)
    Record(_) => Record(children)
    Ctor(name, _) => Ctor(name, children)
    Opaque(name, _) => Opaque(name, children)
    Assoc(name, _) => Assoc(name, children)
    Prop(name, _) =>
      match children {
        [value] => Prop(name, value)
        _ => Prop(name, Omitted)
      }
    AssocProp(_, _) =>
      match children {
        [key, value] => AssocProp(key, value)
        _ => AssocProp(Omitted, Omitted)
      }
  }
}

///|
/// A shallow copy of `info` containing only its “label” (children replaced).
fn debug_info_shallow(info : DebugInfo) -> DebugInfo {
  match info {
    IntLit(_)
    | DoubleLit(_)
    | BoolLit(_)
    | CharLit(_)
    | StringLit(_)
    | Literal(_)
    | Omitted => info
    Array(_) => Array([])
    Record(_) => Record([])
    Ctor(name, _) => Ctor(name, [])
    Opaque(name, _) => Opaque(name, [])
    Assoc(name, _) => Assoc(name, [])
    Prop(name, _) => Prop(name, Omitted)
    AssocProp(_, _) => AssocProp(Omitted, Omitted)
  }
}
