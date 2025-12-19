///|
/// Direct structural representation for debugging/diffing/pretty-printing.
///
/// `pub` makes it readonly outside this package: it can be pattern-matched but
/// not directly constructed. Use the smart constructors below.
///
/// Design notes:
/// - `Record` is encoded as `Record([Prop(name, value), ...])` (not as an array
///   of `(String, Repr)` pairs) to keep generic traversal/rewrite code simple:
///   every tree edge is a `Repr`, so `children/with_children`, pruning, and diff
///   can work uniformly across node kinds.
/// - Labeled constructor arguments are encoded as `Ctor(name, [Arg(label, value), ...])`,
///   which supports mixing positional and labeled args.
/// - `Assoc` is encoded as `Assoc([AssocProp(key, value), ...])`, which is
///   intended for “map-like” collections (MoonBit map literals like `{ k: v }`).
/// - `Opaque` is intended for “container-like” wrappers that keep a type/tag but
///   otherwise behave structurally through their children.
pub enum Repr {
  UnitLit
  /// Integer literal leaf.
  IntLit(Int)
  /// Floating-point literal leaf.
  DoubleLit(Double)
  /// Boolean literal leaf.
  BoolLit(Bool)
  /// Character literal leaf.
  CharLit(Char)
  /// String literal leaf.
  StringLit(String)
  /// Tuple node. Children are the tuple elements (`Tuple([])` is unit).
  Tuple(Array[Repr])
  /// Array container node.
  Array(Array[Repr])
  /// Record container node. Conventionally contains only `Prop` children.
  Record(Array[Repr])
  /// Record field node. Conventionally appears only under `Record`.
  Prop(String, Repr)
  /// Labeled argument node. Conventionally appears only under `Ctor`.
  Arg(String, Repr)
  /// Constructor/application node: `Ctor(name, args)`.
  Ctor(String, Array[Repr])
  /// Opaque wrapper node: prints as `<name>` or `<name: ...>` and keeps children.
  Opaque(String, Array[Repr])
  /// Pre-rendered leaf string (already formatted, no quoting/escaping applied).
  Literal(String)
  /// Association/kv container for map literals.
  Assoc(Array[Repr])
  /// Key/value node. Conventionally appears only under `Assoc`.
  AssocProp(Repr, Repr)
  /// Pruned subtree marker used by depth-limited pretty-printing.
  Omitted
} derive(Eq, Compare)

///|
/// Smart constructors for `Repr` (constructible outside the package).
pub fn Repr::int(x : Int) -> Repr {
  IntLit(x)
}

///|
/// Construct a `DoubleLit` leaf.
pub fn Repr::double(x : Double) -> Repr {
  DoubleLit(x)
}

///|
/// Construct a `BoolLit` leaf.
pub fn Repr::bool(x : Bool) -> Repr {
  BoolLit(x)
}

///|
/// Construct a `CharLit` leaf.
pub fn Repr::char(x : Char) -> Repr {
  CharLit(x)
}

///|
/// Construct a `StringLit` leaf.
pub fn Repr::string(x : String) -> Repr {
  StringLit(x)
}

///|
/// Construct a `Tuple` node from pre-built child `Repr`s.
pub fn Repr::tuple(children : Array[Repr]) -> Repr {
  Tuple(children)
}

///|
/// Construct an `Array` node from pre-built child `Repr`s.
pub fn Repr::array(children : Array[Repr]) -> Repr {
  Array(children)
}

///|
/// Construct a `Record` node from pre-built child `Repr`s.
pub fn Repr::record(fields : Map[String, Repr]) -> Repr {
  Record(fields.to_array().map(fn(p) { Repr::Prop(p.0, p.1) }))
}

///|
/// Construct a `Prop(name, value)` record field node.
pub fn Repr::prop(name : String, value : Repr) -> Repr {
  Prop(name, value)
}

///|
/// Construct a `Arg(label, value)` labeled constructor argument node.
pub fn Repr::arg(label : String, value : Repr) -> Repr {
  Arg(label, value)
}

///|
/// Construct a `Ctor(name, args)` node.
pub fn Repr::ctor(name : String, args : Array[Repr]) -> Repr {
  Ctor(name, args)
}

///|
/// Construct an `Opaque(name, children)` node.
///
/// This is useful for values where you want to keep a tag/type name but still
/// show a structural summary through children (e.g. `<Map: {...}>`).
pub fn Repr::opaque_node(name : String, children : Array[Repr]) -> Repr {
  Opaque(name, children)
}

///|
/// Construct a `Literal(value)` leaf (already formatted).
pub fn Repr::literal(value : String) -> Repr {
  Literal(value)
}

///|
/// Construct an `Assoc(children)` node from pre-built child `Repr`s.
///
/// Prefer `assoc([(k, v), ...])` when you have key/value pairs; it ensures
/// the `Assoc([AssocProp(..), ...])` convention.
pub fn Repr::assoc(children : Array[Repr]) -> Repr {
  Assoc(children)
}

///|
/// Construct an `AssocProp(key, value)` key/value node.
pub fn Repr::assoc_prop(key : Repr, value : Repr) -> Repr {
  AssocProp(key, value)
}

///|
/// Construct an `Omitted` marker node.
pub fn Repr::omitted() -> Repr {
  Omitted
}

///|
/// Child nodes of a `Repr` node.
pub fn Repr::children(self : Repr) -> Array[Repr] {
  match self {
    UnitLit
    | IntLit(_)
    | DoubleLit(_)
    | BoolLit(_)
    | CharLit(_)
    | StringLit(_)
    | Literal(_)
    | Omitted => []
    Tuple(xs)
    | Array(xs)
    | Record(xs)
    | Ctor(_, xs)
    | Opaque(_, xs)
    | Assoc(xs) => xs
    Prop(_, value) | Arg(_, value) => [value]
    AssocProp(key, value) => [key, value]
  }
}

///|
/// Rebuild a `Repr` node with a new child list (payload is preserved).
///
/// Notes:
/// - Leaf nodes ignore `children` and return themselves.
/// - `Prop` expects exactly one child and falls back to `Prop(name, Omitted)`.
/// - `AssocProp` expects exactly two children and falls back to `AssocProp(Omitted, Omitted)`.
pub fn Repr::with_children(self : Repr, children : Array[Repr]) -> Repr {
  match self {
    UnitLit
    | IntLit(_)
    | DoubleLit(_)
    | BoolLit(_)
    | CharLit(_)
    | StringLit(_)
    | Literal(_)
    | Omitted => self
    Tuple(_) => Tuple(children)
    Array(_) => Array(children)
    Record(_) => Record(children)
    Ctor(name, _) => Ctor(name, children)
    Opaque(name, _) => Opaque(name, children)
    Assoc(_) => Assoc(children)
    Prop(name, _) =>
      match children {
        [value] => Prop(name, value)
        _ => Prop(name, Omitted)
      }
    Arg(label, _) =>
      match children {
        [value] => Arg(label, value)
        _ => Arg(label, Omitted)
      }
    AssocProp(_, _) =>
      match children {
        [key, value] => AssocProp(key, value)
        _ => AssocProp(Omitted, Omitted)
      }
  }
}

///|
/// Traverse a `Repr` tree and rewrite each node with `f`.
///
/// `f` runs after children are traversed (post-order), so it sees rewritten
/// children and can hide fields by rewriting `Prop`/`Arg` nodes.
pub fn Repr::traverse(self : Repr, f : (Repr) -> Repr) -> Repr {
  fn go(node : Repr) -> Repr {
    let children = Repr::children(node)
    let next_children = children.map(fn(child) { go(child) })
    f(Repr::with_children(node, next_children))
  }

  go(self)
}

///|
/// Fold a `Repr` tree into a single value.
///
/// `f` runs after children are folded (post-order) and receives their results.
pub fn[T] Repr::fold(self : Repr, f : (Repr, Array[T]) -> T) -> T {
  fn go(node : Repr) -> T {
    let children = Repr::children(node)
    let folded = children.map(fn(child) { go(child) })
    f(node, folded)
  }

  go(self)
}

///|
/// Convert a `Repr` tree into a JSON value.
///
/// Records become JSON objects, arrays/tuples become JSON arrays, and
/// constructors/opaque nodes are encoded with `$tag`/`$args` and
/// `$opaque`/`$value` objects. Associations become JSON objects when keys are
/// strings, otherwise they fall back to arrays of `[key, value]` pairs.
pub fn Repr::to_json(self : Repr) -> Json {
  fn merge_object_entries(children : Array[Json]) -> Map[String, Json]? {
    let pairs : Array[(String, Json)] = []
    for child in children {
      match child {
        Json::Object(map) =>
          for pair in map.to_array() {
            pairs.push(pair)
          }
        _ => return None
      }
    }
    Some(Map::from_array(pairs[:]))
  }

  fn assoc_entries(children : Array[Json]) -> Map[String, Json]? {
    let pairs : Array[(String, Json)] = []
    for child in children {
      match child {
        Json::Array(items) =>
          if items.length() == 2 {
            match items[0] {
              Json::String(key) => pairs.push((key, items[1]))
              _ => return None
            }
          } else {
            return None
          }
        _ => return None
      }
    }
    Some(Map::from_array(pairs[:]))
  }

  fn object_single(key : String, value : Json) -> Json {
    let pairs : Array[(String, Json)] = [(key, value)]
    Json::object(Map::from_array(pairs[:]))
  }

  fn object_label_value(label : String, value : Json) -> Json {
    let pairs : Array[(String, Json)] = [
      ("$label", Json::string(label)),
      ("$value", value),
    ]
    Json::object(Map::from_array(pairs[:]))
  }

  Repr::fold(self, fn(node, children) {
    match node {
      UnitLit => Json::null()
      IntLit(x) => Json::number(x.to_double(), repr=repr(x))
      DoubleLit(x) => Json::number(x)
      BoolLit(x) => Json::boolean(x)
      CharLit(c) => Json::string("\{c}")
      StringLit(s) => Json::string(s)
      Literal(s) => Json::string(s)
      Tuple(_) | Array(_) => Json::array(children)
      Record(_) =>
        match merge_object_entries(children) {
          Some(map) => Json::object(map)
          None => Json::array(children)
        }
      Prop(name, _) =>
        match children {
          [value] => object_single(name, value)
          _ => object_single(name, Json::null())
        }
      Arg(label, _) =>
        match children {
          [value] => object_label_value(label, value)
          _ => object_label_value(label, Json::null())
        }
      Ctor(name, _) =>
        Json::object(
          Map::from_array(
            [("$tag", Json::string(name)), ("$args", Json::array(children))][:],
          ),
        )
      Opaque(name, _) =>
        Json::object(
          Map::from_array(
            [("$opaque", Json::string(name)), ("$value", Json::array(children))][:],
          ),
        )
      Assoc(_) =>
        match assoc_entries(children) {
          Some(map) => Json::object(map)
          None => Json::array(children)
        }
      AssocProp(_, _) =>
        match children {
          [key, value] => Json::array([key, value])
          _ => Json::array([])
        }
      Omitted => Json::null()
    }
  })
}

///|
/// A shallow copy of `self` containing only its “label” (children replaced).
///
/// This is used by diff/pretty-print when the structure is preserved but
/// children are rendered separately.
pub fn Repr::shallow(self : Repr) -> Repr {
  match self {
    UnitLit
    | IntLit(_)
    | DoubleLit(_)
    | BoolLit(_)
    | CharLit(_)
    | StringLit(_)
    | Literal(_)
    | Omitted => self
    Tuple(_) => Tuple([])
    Array(_) => Array([])
    Record(_) => Record([])
    Ctor(name, _) => Ctor(name, [])
    Opaque(name, _) => Opaque(name, [])
    Assoc(_) => Assoc([])
    Prop(name, _) => Prop(name, Omitted)
    Arg(label, _) => Arg(label, Omitted)
    AssocProp(_, _) => AssocProp(Omitted, Omitted)
  }
}

///|
/// Construct a unit `Repr` (`()`).
pub fn unit() -> Repr {
  Repr::UnitLit
}

///|
/// Construct a constructor/application `Repr` with a name and argument list.
pub fn ctor(name : String, args : Array[Repr]) -> Repr {
  Repr::ctor(name, args)
}

///|
/// Construct a labeled argument node.
pub fn arg(label : String, value : Repr) -> Repr {
  Repr::arg(label, value)
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
  opaque_child(name, Repr::array(contents))
}

///|
/// Construct an association/kv `Repr` from key/value `Repr` pairs.
pub fn assoc(contents : Array[(Repr, Repr)]) -> Repr {
  Repr::assoc(
    contents.map(fn(pair) {
      let (k, v) = pair
      Repr::assoc_prop(k, v)
    }),
  )
}
