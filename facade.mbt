///|
/// Re-export `Repr` and smart constructors from `@repr`.
/// Use `Repr::int(x)`, `Repr::string(s)`, etc. to construct values.
pub using @repr {type Repr}

///|
/// Diffing (forwarded to `@diff`).
pub using @diff {
  type DiffOptions,
  type ReprDelta,
  default_diff_options,
  diff_repr,
  diff_repr_with,
}

///|
pub fn diff_options(max_relative_error~ : Double) -> DiffOptions {
  { max_relative_error, }
}

///|
/// Pretty-printing (forwarded to `@pp`).
pub using @pp {
  type PrettyPrintOptions,
  default_pretty_print_options,
  pretty_print_repr,
  pretty_print_repr_with,
  pretty_print_delta,
  pretty_print_delta_with,
}

///|
pub fn pretty_print_options(
  max_depth~ : Int?,
  compact_threshold~ : Int,
  use_ansi~ : Bool,
) -> PrettyPrintOptions {
  { max_depth, compact_threshold, use_ansi }
}
