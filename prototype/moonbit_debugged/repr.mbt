///|
/// Internal label type for `Repr` trees.
enum Label {
  LInt(Int)
  LDouble(Double)
  LBool(Bool)
  LChar(Char)
  LString(String)
  LArray
  LRecord
  LProp(String)
  LApp(String)
  LOpaque(String)
  LLiteral(String)
  LAssoc(String)
  LAssocProp
  LOmitted
} derive(Eq, Compare)

///|
/// Structural representation for debugging/diffing (a `Tree` of `Label`s).
pub struct Repr(Tree[Label]) derive(Eq, Compare)

///|
/// Extract the underlying tree from a `Repr`.
fn un_repr(r : Repr) -> Tree[Label] {
  r.0
}

///|
/// Construct an integer `Repr`.
pub fn int(x : Int) -> Repr {
  Repr(Node(Label::LInt(x), []))
}

///|
/// Construct a double `Repr`.
pub fn double(x : Double) -> Repr {
  Repr(Node(Label::LDouble(x), []))
}

///|
/// Construct a boolean `Repr`.
pub fn bool(x : Bool) -> Repr {
  Repr(Node(Label::LBool(x), []))
}

///|
/// Construct a char `Repr`.
pub fn char(x : Char) -> Repr {
  Repr(Node(Label::LChar(x), []))
}

///|
/// Construct a string `Repr`.
pub fn string(x : String) -> Repr {
  Repr(Node(Label::LString(x), []))
}

///|
/// Construct an array `Repr` from pre-built child `Repr`s.
pub fn array(xs : Array[Repr]) -> Repr {
  Repr(Node(Label::LArray, xs.map(fn(r) { un_repr(r) })))
}

///|
/// Convert record field pairs into labeled property subtrees.
fn make_props(fields : Array[(String, Repr)]) -> Array[Tree[Label]] {
  fields.map(fn(field) {
    let (name, value) = field
    Node(Label::LProp(name), [un_repr(value)])
  })
}

///|
/// Construct a record `Repr` from field name/value pairs.
pub fn record(fields : Array[(String, Repr)]) -> Repr {
  Repr(Node(Label::LRecord, make_props(fields)))
}

///|
/// Construct a constructor/application `Repr` with a name and argument list.
pub fn ctor(name : String, args : Array[Repr]) -> Repr {
  Repr(Node(Label::LApp(name), args.map(fn(r) { un_repr(r) })))
}

///|
/// Construct an opaque wrapper `Repr` with a single child.
pub fn opaque_child(name : String, child : Repr) -> Repr {
  Repr(Node(Label::LOpaque(name), [un_repr(child)]))
}

///|
/// Construct an opaque wrapper `Repr` with no children.
pub fn opaque_(name : String) -> Repr {
  Repr(Node(Label::LOpaque(name), []))
}

///|
/// Construct an opaque wrapper `Repr` containing a literal leaf (already formatted).
pub fn opaque_literal(name : String, value : String) -> Repr {
  Repr(Node(Label::LOpaque(name), [Node(Label::LLiteral(value), [])]))
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
    Node(
      Label::LAssoc(name),
      contents.map(fn(pair) {
        let (k, v) = pair
        Node(Label::LAssocProp, [un_repr(k), un_repr(v)])
      }),
    ),
  )
}
