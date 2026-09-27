///|
/// Convert a value into a structural `Repr` for pretty-printing and diffing.
///
/// Once a type implements this trait:
/// - `debug(x)` builds a `Repr`
/// - `pretty_print(x, ...)`, `diff(x, ...)`, and `pretty_print_diff(x, ...)` work out of the box
pub(open) trait Debug {
  fn debug(Self) -> @repr.Repr
}

///|
/// Build a `Repr` for any `T` that implements `Debug`.
pub fn[T : Debug] debug(x : T) -> @repr.Repr {
  T::debug(x)
}

///|
/// Pretty-print a value.
///
/// Optional parameters:
/// - `max_depth?`: maximum expansion depth; deeper subtrees are replaced with `...`.
///   Defaults to `4` when `None`.
/// - `compact_threshold?`: compact-vs-multiline layout threshold.
///   The printer uses a heuristic “size” for nodes; when the structure is deemed
///   small enough under this threshold, it is kept on one line, otherwise it is
///   broken into multiple lines.
///   Larger values prefer single-line output. Defaults to `80` when `None`.
/// - `use_ansi?`: whether to emit ANSI color escape codes. Defaults to `true` when `None`.
pub fn[T : Debug] pretty_print(
  x : T,
  max_depth? : Int,
  compact_threshold? : Int,
  use_ansi? : Bool,
) -> String {
  @pp.pretty_print_repr(debug(x), max_depth?, compact_threshold?, use_ansi?)
}

///|
/// Diff two values (by diffing their `Repr`).
///
/// Optional parameters:
/// - `max_relative_error?`: relative-error tolerance used for `DoubleLit` comparisons.
///   Larger values make floats less likely to be considered different.
///   Defaults to `1e-12` when `None`.
pub fn[T : Debug] diff(
  x : T,
  y : T,
  max_relative_error? : Double,
) -> @diff.ReprDelta {
  @diff.diff_repr(debug(x), debug(y), max_relative_error?)
}

///|
/// Pretty-print the diff between two values.
///
/// Optional parameters:
/// - `max_depth?`: maximum expansion depth; defaults to `4` when `None`.
/// - `compact_threshold?`: compact-vs-multiline layout threshold (heuristic one-line vs multiline).
///   Larger values prefer single-line output. Defaults to `80` when `None`.
/// - `use_ansi?`: whether to emit ANSI color escape codes; defaults to `true` when `None`.
/// - `max_relative_error?`: float tolerance for `DoubleLit`; defaults to `1e-12` when `None`.
pub fn[T : Debug] pretty_print_diff(
  x : T,
  y : T,
  max_depth? : Int,
  compact_threshold? : Int,
  use_ansi? : Bool,
  max_relative_error? : Double,
) -> String {
  @pp.pretty_print_delta(
    diff(x, y, max_relative_error?),
    max_depth?,
    compact_threshold?,
    use_ansi?,
  )
}
