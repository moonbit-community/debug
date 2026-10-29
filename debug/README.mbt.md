# moonbit-community/debug

This legacy package is withdrawn from Mooncakes in favor of
`moonbitlang/core/debug`. New code should use the standard library `Debug` trait,
`derive(Debug)`, `debug_inspect`, and `render`. This checkout retains compatibility
tests for existing users; it is not a new publication of the withdrawn package.

An experimental `Debug` + `diff` + pretty-printer library for MoonBit. We plan 
to add this to the standard library when it is more mature.

It provides:

* A `Debug` trait that turns values into a structural `Repr`
* A tree-based `diff` (`ReprDelta`) with configurable float tolerance
* A pretty printer for both `Repr` and `ReprDelta` (optionally with ANSI marks)
* A binary to auto-generate `Debug` implementations for your types

Goals: 

* A way to debug values and show the diff, with pretty-printing

* Replacing Some Roles of `Show` and `ToJson`

  The current `Show` trait produces output that is not suitable for debugging, as it lacks indentation and line breaks.  
  The `ToJson` trait produces JSON, which is more readable with `@json.inspect` but not ideal for MoonBit-specific types (e.g., enums).  
  It can also confuse users who expect `ToJson` to produce structured data rather than a debug representation.

  With the introduction of `Debug` , the `Show` trait can focus on producing specialized output (such as `Json::stringify` , `String::to_string` , etc.), and `derive(Show)` will be deprecated.

Non-goals:

* Deserializing from `Repr` back to original values
* Output a valid moonbit code representation

## Project structure

The legacy generator is a separate executable module:

* `debug/`: the main library module
* `debug_deriving/`: the tool that generates legacy `Debug` implementations
* `debug_deriving_examples/`: an example using the last published library
* `debug_deriving_examples_local_deps/`: the same example using this checkout

Run `./check.sh` from the repository root to install the checked-out generator
into a temporary directory and validate all four module roots.

## Quickstart

Run the small demo:

```bash
moon run cmd/main
```

In another package, import this module in `moon.pkg.json` :

```json
{
  "import": [{ "path": "moonbit-community/debug", "alias": "dbg" }]
}
```

Then call:

```mbt nocheck
///|
fn show_examples {
  println(@dbg.pretty_print([1, 2, 3]))
  println(@dbg.pretty_print_diff(Some(1), Some(2)))
}
```

## Implement `Debug` for your own types

Use `record` , `ctor` , `array` , and friends to build a `Repr` :

```mbt nocheck
///|
struct Person {
  name : String
  age : Int32
}

///|
pub impl @dbg.Debug for Person with fn debug(self) {
  @dbg.record([("name", @dbg.debug(self.name)), ("age", @dbg.debug(self.age))])
}
```

## Auto deriving `Debug`

For an existing project that still needs the legacy generator, install it from
this checkout with `moon install ./debug_deriving` from the repository root.
Ensure the installation directory (normally `~/.moon/bin`) is on `PATH`.
The removed `bin-deps` manifest option is no longer used.

In the consuming package's `moon.pkg`, configure:

```moonbit nocheck
options(
  "pre-build": [
    {
      "command": "debug_deriving $input $output",
      "input": "input.mbt",
      "output": "output.mbt",
    },
  ],
)
```

Then add `#debug.derive` to the legacy input types:

```mbt nocheck
///|
#debug.derive
struct Pos(Int32, Int32)
```

## Options

All options are passed directly as optional parameters to functions:

### Pretty printing

* `max_depth?`: optional depth limit; omit for default (4), or pass `max_depth=n` to prune
* `threshold?`: controls single-line vs multi-line rendering (default: 8)
* `use_ansi?`: enables `+`/`-` with ANSI colors in diffs (default: true)

### Diffing

* `max_relative_error?`: float tolerance for comparing `Double` values

See `docs_test.mbt` and `examples_test.mbt` for runnable, snapshot-based
examples.

## Doctest examples

```mbt check
///|
test {
  inspect(@debug.pretty_print([1, 2, 3]), content="[1, 2, 3]")
  inspect(
    @debug.pretty_print_diff(1, 2, compact_threshold=100, use_ansi=false),
    content="-1 +2",
  )
}
```
