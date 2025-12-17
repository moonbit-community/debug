///|
/// Tree-shaped diff between two `DebugInfo` values.
enum DebugDelta {
  Same(DebugInfo, Array[DebugDelta])
  Different(DebugInfo, DebugInfo)
  Extra1(DebugInfo)
  Extra2(DebugInfo)
} derive(Eq, Compare)

///|
/// A diff of two `Repr` values.
pub struct ReprDelta(DebugDelta) derive(Eq, Compare)

///|
/// Extract the underlying delta from a `ReprDelta`.
fn un_repr_delta(d : ReprDelta) -> DebugDelta {
  d.0
}

///|
/// Options for diffing, including float tolerance for `Double`.
pub(all) struct DiffOptions {
  max_relative_error : Double
} derive(Show, Eq)

///|
/// Default diff options used by `diff_repr`.
pub let default_diff_options : DiffOptions = {
  max_relative_error: 0.000000000001,
}

///|
/// Absolute value for `Double`.
fn double_abs(x : Double) -> Double {
  if x < 0.0 {
    -x
  } else {
    x
  }
}

///|
/// Maximum of two `Double` values.
fn double_max(x : Double, y : Double) -> Double {
  if x > y {
    x
  } else {
    y
  }
}

///|
/// Relative error metric used for approximate float comparisons.
fn relative_error(x : Double, y : Double) -> Double {
  if x == y {
    0.0
  } else {
    let denom = double_max(double_abs(x), double_abs(y))
    if denom == 0.0 {
      double_abs(x - y)
    } else {
      double_abs(x - y) / denom
    }
  }
}

///|
/// Compare two node “labels”, with float tolerance for `DoubleLit`.
fn info_approx_eq(
  max_relative_error : Double,
  x : DebugInfo,
  y : DebugInfo,
) -> Bool {
  match (x, y) {
    (DoubleLit(x1), DoubleLit(y1)) =>
      relative_error(x1, y1) <= max_relative_error
    (IntLit(x1), IntLit(y1)) => x1 == y1
    (BoolLit(x1), BoolLit(y1)) => x1 == y1
    (CharLit(x1), CharLit(y1)) => x1 == y1
    (StringLit(x1), StringLit(y1)) => x1 == y1
    (Literal(x1), Literal(y1)) => x1 == y1
    (Omitted, Omitted) => true
    (Array(_), Array(_)) => true
    (Record(_), Record(_)) => true
    (Prop(n1, _), Prop(n2, _)) => n1 == n2
    (Ctor(n1, _), Ctor(n2, _)) => n1 == n2
    (Opaque(n1, _), Opaque(n2, _)) => n1 == n2
    (Assoc(n1, _), Assoc(n2, _)) => n1 == n2
    (AssocProp(_, _), AssocProp(_, _)) => true
    _ => false
  }
}

///|
/// Labels that are treated as structural “containers” (may be collapsed in diffs).
fn info_is_unimportant(info : DebugInfo) -> Bool {
  match info {
    AssocProp(_, _) | Array(_) | Record(_) => true
    _ => false
  }
}

///|
/// Returns `true` iff `p` holds for every element.
fn[T] tree_all(xs : Array[T], p : (T) -> Bool) -> Bool {
  let mut ok = true
  for x in xs {
    if !p(x) {
      ok = false
      break
    }
  }
  ok
}

///|
/// Core `DebugInfo` diff: returns a `DebugDelta` describing differences.
fn diff_info_with(
  left : DebugInfo,
  right : DebugInfo,
  max_relative_error~ : Double,
) -> DebugDelta {
  fn differing(d : DebugDelta) -> Bool {
    match d {
      Same(_, _) => false
      _ => true
    }
  }

  fn go(left_node : DebugInfo, right_node : DebugInfo) -> DebugDelta {
    if info_approx_eq(max_relative_error, left_node, right_node) {
      let xs = debug_info_children(left_node)
      let ys = debug_info_children(right_node)
      let xlen = xs.length()
      let ylen = ys.length()
      let min_len = if xlen < ylen { xlen } else { ylen }
      let children : Array[DebugDelta] = for i = 0, acc = [] {
        if i < min_len {
          continue i + 1, acc + [go(xs[i], ys[i])]
        } else {
          break acc
        }
      }
      let children = if xlen < ylen {
        children + ys[min_len:ylen].to_array().map(fn(t) { Extra2(t) })
      } else if xlen > ylen {
        children + xs[min_len:xlen].to_array().map(fn(t) { Extra1(t) })
      } else {
        children
      }
      if info_is_unimportant(left_node) && tree_all(children, differing) {
        Different(left_node, right_node)
      } else {
        Same(debug_info_shallow(left_node), children)
      }
    } else {
      Different(left_node, right_node)
    }
  }

  go(left, right)
}

///|
/// Diff two `Repr` values using explicit `DiffOptions`.
pub fn diff_repr_with(opts : DiffOptions, x : Repr, y : Repr) -> ReprDelta {
  ReprDelta(
    diff_info_with(
      un_repr(x),
      un_repr(y),
      max_relative_error=opts.max_relative_error,
    ),
  )
}

///|
/// Diff two `Repr` values using `default_diff_options`.
pub fn diff_repr(x : Repr, y : Repr) -> ReprDelta {
  diff_repr_with(default_diff_options, x, y)
}
