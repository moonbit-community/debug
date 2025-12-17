///|
/// Direct structural representation for debugging/diffing/pretty-printing.
///
/// `pub` makes it readonly outside this package: it can be pattern-matched but
/// not directly constructed. Use the smart constructors below.
pub enum Repr {
  IntLit(Int)
  DoubleLit(Double)
  BoolLit(Bool)
  CharLit(Char)
  StringLit(String)
  Array(Array[Repr])
  Record(Array[Repr])
  Prop(String, Repr)
  Ctor(String, Array[Repr])
  Opaque(String, Array[Repr])
  Literal(String)
  Assoc(String, Array[Repr])
  AssocProp(Repr, Repr)
  Omitted
} derive(Eq, Compare)

///|
/// Smart constructors for `Repr` (constructible outside the package).
pub fn Repr::int_lit(x : Int) -> Repr {
  IntLit(x)
}

///|
pub fn Repr::double_lit(x : Double) -> Repr {
  DoubleLit(x)
}

///|
pub fn Repr::bool_lit(x : Bool) -> Repr {
  BoolLit(x)
}

///|
pub fn Repr::char_lit(x : Char) -> Repr {
  CharLit(x)
}

///|
pub fn Repr::string_lit(x : String) -> Repr {
  StringLit(x)
}

///|
pub fn Repr::array(children : Array[Repr]) -> Repr {
  Array(children)
}

///|
pub fn Repr::record(children : Array[Repr]) -> Repr {
  Record(children)
}

///|
pub fn Repr::prop(name : String, value : Repr) -> Repr {
  Prop(name, value)
}

///|
pub fn Repr::ctor(name : String, args : Array[Repr]) -> Repr {
  Ctor(name, args)
}

///|
pub fn Repr::opaque_node(name : String, children : Array[Repr]) -> Repr {
  Opaque(name, children)
}

///|
pub fn Repr::literal(value : String) -> Repr {
  Literal(value)
}

///|
pub fn Repr::assoc(name : String, children : Array[Repr]) -> Repr {
  Assoc(name, children)
}

///|
pub fn Repr::assoc_prop(key : Repr, value : Repr) -> Repr {
  AssocProp(key, value)
}

///|
pub fn Repr::omitted() -> Repr {
  Omitted
}

///|
/// Child nodes of a `Repr` node.
pub fn Repr::children(self : Repr) -> Array[Repr] {
  match self {
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
/// Rebuild a `Repr` node with a new child list (payload is preserved).
pub fn Repr::with_children(self : Repr, children : Array[Repr]) -> Repr {
  match self {
    IntLit(_)
    | DoubleLit(_)
    | BoolLit(_)
    | CharLit(_)
    | StringLit(_)
    | Literal(_)
    | Omitted => self
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
/// A shallow copy of `self` containing only its “label” (children replaced).
pub fn Repr::shallow(self : Repr) -> Repr {
  match self {
    IntLit(_)
    | DoubleLit(_)
    | BoolLit(_)
    | CharLit(_)
    | StringLit(_)
    | Literal(_)
    | Omitted => self
    Array(_) => Array([])
    Record(_) => Record([])
    Ctor(name, _) => Ctor(name, [])
    Opaque(name, _) => Opaque(name, [])
    Assoc(name, _) => Assoc(name, [])
    Prop(name, _) => Prop(name, Omitted)
    AssocProp(_, _) => AssocProp(Omitted, Omitted)
  }
}

///|
/// Construct an integer `Repr`.
pub fn int(x : Int) -> Repr {
  Repr::int_lit(x)
}

///|
/// Construct a double `Repr`.
pub fn double(x : Double) -> Repr {
  Repr::double_lit(x)
}

///|
/// Construct a boolean `Repr`.
pub fn bool(x : Bool) -> Repr {
  Repr::bool_lit(x)
}

///|
/// Construct a char `Repr`.
pub fn char(x : Char) -> Repr {
  Repr::char_lit(x)
}

///|
/// Construct a string `Repr`.
pub fn string(x : String) -> Repr {
  Repr::string_lit(x)
}

///|
/// Construct an array `Repr` from pre-built child `Repr`s.
pub fn array(xs : Array[Repr]) -> Repr {
  Repr::array(xs)
}

///|
/// Convert record field pairs into property nodes.
fn make_props(fields : Array[(String, Repr)]) -> Array[Repr] {
  fields.map(fn(field) {
    let (name, value) = field
    Repr::prop(name, value)
  })
}

///|
/// Construct a record `Repr` from field name/value pairs.
pub fn record(fields : Array[(String, Repr)]) -> Repr {
  Repr::record(make_props(fields))
}

///|
/// Construct a constructor/application `Repr` with a name and argument list.
pub fn ctor(name : String, args : Array[Repr]) -> Repr {
  Repr::ctor(name, args)
}

///|
/// Construct an opaque wrapper `Repr` with a single child.
pub fn opaque_child(name : String, child : Repr) -> Repr {
  Repr::opaque_node(name, [child])
}

///|
/// Construct an opaque wrapper `Repr` with no children.
pub fn opaque_(name : String) -> Repr {
  Repr::opaque_node(name, [])
}

///|
/// Construct an opaque wrapper `Repr` containing a literal leaf (already formatted).
pub fn opaque_literal(name : String, value : String) -> Repr {
  Repr::opaque_node(name, [Repr::literal(value)])
}

///|
/// Convenience helper for “collection-like” reprs: `<name: [ ... ]>`.
pub fn collection(name : String, contents : Array[Repr]) -> Repr {
  opaque_child(name, array(contents))
}

///|
/// Construct an association/kv `Repr` from key/value `Repr` pairs.
pub fn assoc(name : String, contents : Array[(Repr, Repr)]) -> Repr {
  Repr::assoc(
    name,
    contents.map(fn(pair) {
      let (k, v) = pair
      Repr::assoc_prop(k, v)
    }),
  )
}
