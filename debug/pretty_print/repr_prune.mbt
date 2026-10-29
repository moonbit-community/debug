///|
/// Prune a `Repr` tree to a given depth (replacing pruned subtrees).
///
/// Parameters:
/// - `depth~`: maximum depth. Values `<= 0` are treated as `1`.
/// - `replacement?`: the node used to replace pruned subtrees.
///   Defaults to `Repr::omitted()`.
///
/// Semantics:
/// - Leaf nodes are never replaced.
/// - When the depth budget is exhausted and the node has children:
///   - if `info_adds_depth() == false`, pruning continues into its children;
///   - otherwise the whole subtree is replaced by `replacement`.
pub fn prune_info(
  info : @repr.Repr,
  replacement~ : @repr.Repr = @repr.Repr::omitted(),
  depth~ : Int32,
) -> @repr.Repr {
  fn go(d : Int32, node : @repr.Repr) -> @repr.Repr {
    let children = node.children()
    if d <= 0 {
      if children.is_empty() {
        node
      } else if !node.info_adds_depth() {
        node.with_children(children.map(fn(child) { go(d, child) }))
      } else {
        replacement
      }
    } else if children.is_empty() {
      node
    } else {
      let next_depth = if node.info_adds_depth() { d - 1 } else { d }
      node.with_children(children.map(fn(child) { go(next_depth, child) }))
    }
  }

  go(Int32::max(1, depth), info)
}
