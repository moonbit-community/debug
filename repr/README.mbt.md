# `dii_user/moonbit_debugged/repr`

This package defines `Repr`: a small, structural, tree-shaped representation
used by `dii_user/moonbit_debugged` for:

- pretty-printing (`dii_user/moonbit_debugged/pretty_print`)
- diffing (`dii_user/moonbit_debugged/diff`)
- the `Debug` trait (`dii_user/moonbit_debugged`)

`Repr` is exported as a readonly enum (`pub enum Repr`), so it can be
pattern-matched outside the package but not directly constructed. Use the smart
constructors (`Repr::...`) or the convenience functions (`int`, `record`, ...).

## Records

A record node is represented structurally as:

- `Record([Prop(name, value), ...])`

### Why `Record(Array[Repr])` + `Prop`?

You might wonder why we don’t model records more “directly” as something like
`Record(Array[(String, Repr)])`. The choice here is deliberate:

- **Uniform traversal/rewrite**: every tree edge is a `Repr`. Generic utilities
  like `Repr::children`, `Repr::with_children`, pruning, and the diff algorithm
  can treat records exactly like arrays/ctors/opaque nodes without special-cases
  for `(String, Repr)` pairs.
- **Field names live in the tree**: a field is a real node (`Prop(name, ...)`),
  so pretty-printing and diffing can use the same “label + children” pipeline
  everywhere.
- **Keeps the public API small**: an alternative representation would either
  complicate the `children/with_children` contract (because record “children”
  aren’t `Repr` values) or require additional parallel APIs just for records.

If you want “map-like” semantics (key/value pairs as first-class children), use
`Assoc(name, [AssocProp(key, value), ...])`, which is what the `Debug` instance
for `Map` uses.

So for a value conceptually shaped like:

```text
record { x : Int; y : String }
```

the corresponding `Repr` is:

```text
Record([
  Prop("x", IntLit(...)),
  Prop("y", StringLit(...)),
])
```

### Example (runnable)

```mbt test
let r : Repr = @repr.Repr::record({ "x": Repr::int(1), "y": Repr::string("hi") })
match r {
  Repr::Record(
    [Repr::Prop("x", Repr::IntLit(1)), Repr::Prop("y", Repr::StringLit("hi"))]
  ) => ()
  _ => fail("unexpected Repr shape for record {x:Int; y:String}")
}
```

```mbt test
let r : Repr = Repr::record({
  "user": Repr::string("alice"),
  "age": Repr::int(30),
})
match r {
  Repr::Record([Repr::Prop("user", Repr::StringLit("alice")), _]) => ()
  _ => fail("unexpected Repr shape for record")
}
match Repr::to_json(r) {
  Json::Object(map) => {
    match map.get("user") {
      Some(Json::String("alice")) => ()
      _ => fail("expected user to be \"alice\"")
    }
    match map.get("age") {
      Some(Json::Number(x, ..)) => assert_eq(x, 30.0)
      _ => fail("expected age to be number 30")
    }
  }
  _ => fail("expected Json object")
}
```

## Tuples (and unit)

Tuples are represented as:

- `Tuple([a, b, ...])`

Unit is the empty tuple:

- `Tuple([])` (also constructible with `unit()`)

### Example (runnable)

```mbt test
let t : Repr = Repr::tuple([Repr::int(1), Repr::string("x")])
match t {
  Repr::Tuple([Repr::IntLit(1), Repr::StringLit("x")]) => ()
  _ => fail("unexpected Repr shape for tuple (Int, String)")
}
```

## Labeled constructor arguments

MoonBit enum variants (and tuple-struct constructors) can have labeled arguments.
To preserve those labels in a `Repr`, use `Arg(label, value)` nodes as children
of `Ctor`:

- `Ctor("A", [Arg("x", ...), Arg("y", ...)])` prints as `A(x=..., y=...)`
- you can freely mix positional and labeled args:
  `Ctor("B", [Arg("x", ...), ...])` prints as `B(x=..., ...)`

### Example (runnable)

```mbt test
let r : Repr = Repr::ctor("A", [
  Repr::arg("x", Repr::int(1)),
  Repr::arg("y", Repr::string("hi")),
])
match r {
  Repr::Ctor(
    "A",
    [Repr::Arg("x", Repr::IntLit(1)), Repr::Arg("y", Repr::StringLit("hi"))]
  ) => ()
  _ => fail("unexpected Repr shape for labeled ctor A(x=Int, y=String)")
}
```
