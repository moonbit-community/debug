///|
/// Per-node diff markers for `Repr` trees.
enum Delta[T] {
  Same(T)
  Different
  Extra1
  Extra2
  Subtree(T)
} derive(Eq, Compare)

///|
/// A tree-shaped diff of two `Repr` values.
pub struct ReprDelta(Tree[Delta[Label]]) derive(Eq, Compare)

///|
/// Extract the underlying tree from a `ReprDelta`.
fn un_repr_delta(d : ReprDelta) -> Tree[Delta[Label]] {
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
/// Compare two labels with float tolerance when they are `LDouble`.
fn label_approx_eq(max_relative_error : Double, x : Label, y : Label) -> Bool {
  match (x, y) {
    (LDouble(x1), LDouble(y1)) => relative_error(x1, y1) <= max_relative_error
    _ => x == y
  }
}

///|
/// Labels that are treated as structural “containers” (may be collapsed in diffs).
fn label_is_unimportant(label : Label) -> Bool {
  match label {
    LAssocProp | LArray | LRecord => true
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
/// Core tree diff: returns a `Tree[Delta[Label]]` describing differences.
fn diff_tree_with(
  left : Tree[Label],
  right : Tree[Label],
  max_relative_error~ : Double,
) -> Tree[Delta[Label]] {
  fn differing(t : Tree[Delta[Label]]) -> Bool {
    match t {
      Node(Same(_), _) => false
      _ => true
    }
  }

  fn extra(tag : Delta[Label], subtree : Tree[Label]) -> Tree[Delta[Label]] {
    Node(tag, [tree_map(subtree, fn(label) { Subtree(label) })])
  }

  fn go(
    left_node : Tree[Label],
    right_node : Tree[Label],
  ) -> Tree[Delta[Label]] {
    match (left_node, right_node) {
      (Node(x, xs), Node(y, ys)) =>
        if label_approx_eq(max_relative_error, x, y) {
          let xlen = xs.length()
          let ylen = ys.length()
          let min_len = if xlen < ylen { xlen } else { ylen }
          let children : Array[Tree[Delta[Label]]] = for i = 0, acc = [] {
            if i < min_len {
              continue i + 1, acc + [go(xs[i], ys[i])]
            } else {
              break acc
            }
          }
          let children = if xlen < ylen {
            children +
            ys[min_len:ylen].to_array().map(fn(t) { extra(Extra2, t) })
          } else if xlen > ylen {
            children +
            xs[min_len:xlen].to_array().map(fn(t) { extra(Extra1, t) })
          } else {
            children
          }
          if label_is_unimportant(x) && tree_all(children, differing) {
            Node(Different, [
              tree_map(left_node, fn(label) { Subtree(label) }),
              tree_map(right_node, fn(label) { Subtree(label) }),
            ])
          } else {
            Node(Same(x), children)
          }
        } else {
          Node(Different, [
            tree_map(left_node, fn(label) { Subtree(label) }),
            tree_map(right_node, fn(label) { Subtree(label) }),
          ])
        }
    }
  }

  go(left, right)
}

///|
/// Diff two `Repr` values using explicit `DiffOptions`.
pub fn diff_repr_with(opts : DiffOptions, x : Repr, y : Repr) -> ReprDelta {
  ReprDelta(
    diff_tree_with(
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
