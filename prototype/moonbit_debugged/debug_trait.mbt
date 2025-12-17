///|
/// Convert a value into a structural `Repr` for pretty-printing and diffing.
pub(open) trait Debug {
  debug(Self) -> Repr
}

///|
/// Build a `Repr` for any `T` that implements `Debug`.
pub fn[T : Debug] debug(x : T) -> Repr {
  T::debug(x)
}

///|
/// Pretty-print a value with `default_pretty_print_options`.
pub fn[T : Debug] pretty_print(x : T) -> String {
  pretty_print_repr(debug(x))
}

///|
/// Pretty-print a value with explicit `PrettyPrintOptions`.
pub fn[T : Debug] pretty_print_with(opts : PrettyPrintOptions, x : T) -> String {
  pretty_print_repr_with(opts, debug(x))
}

///|
/// Diff two values by diffing their `Repr`.
pub fn[T : Debug] diff(x : T, y : T) -> ReprDelta {
  diff_repr(debug(x), debug(y))
}

///|
/// Diff two values with explicit `DiffOptions` (notably float tolerance).
pub fn[T : Debug] diff_with(opts : DiffOptions, x : T, y : T) -> ReprDelta {
  diff_repr_with(opts, debug(x), debug(y))
}

///|
/// Pretty-print the diff between two values with default options.
pub fn[T : Debug] pretty_print_diff(x : T, y : T) -> String {
  pretty_print_delta(diff(x, y))
}

///|
/// Pretty-print the diff between two values with explicit `PrettyPrintOptions`.
pub fn[T : Debug] pretty_print_diff_with(
  opts : PrettyPrintOptions,
  x : T,
  y : T,
) -> String {
  pretty_print_delta_with(opts, diff(x, y))
}
