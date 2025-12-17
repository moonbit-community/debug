///|
test "diff: arrays collapse when all children differ" {
  let x = @repr.array([@repr.int(1), @repr.int(2)])
  let y = @repr.array([@repr.int(3), @repr.int(4)])
  match ReprDelta::delta(diff_repr(x, y)) {
    DebugDelta::Different(@repr.Repr::Array(_), @repr.Repr::Array(_)) => ()
    _ => fail("expected Different(Array, Array)")
  }
}

///|
test "diff: arrays keep per-element when some children same" {
  let x = @repr.array([@repr.int(1), @repr.int(2)])
  let y = @repr.array([@repr.int(1), @repr.int(3)])
  match ReprDelta::delta(diff_repr(x, y)) {
    DebugDelta::Same(
      @repr.Repr::Array([]),
      [DebugDelta::Same(@repr.Repr::IntLit(1), []), _]
    ) => ()
    _ => fail("expected Same(Array, children...)")
  }
}

///|
test "diff: extra elements are marked" {
  let x = @repr.array([@repr.int(1)])
  let y = @repr.array([@repr.int(1), @repr.int(2)])
  match ReprDelta::delta(diff_repr(x, y)) {
    DebugDelta::Same(
      @repr.Repr::Array([]),
      [
        DebugDelta::Same(@repr.Repr::IntLit(1), []),
        DebugDelta::Extra2(@repr.Repr::IntLit(2)),
      ]
    ) => ()
    _ => fail("expected Same(Array, [Same 1, Extra2 2])")
  }
}

///|
test "diff: tolerant doubles compare same" {
  let opts : DiffOptions = { max_relative_error: 1.0e-12 }
  let x = @repr.double(1.0)
  let y = @repr.double(1.0 + 1.0e-13)
  match ReprDelta::delta(diff_repr_with(opts, x, y)) {
    DebugDelta::Same(@repr.Repr::DoubleLit(_), []) => ()
    _ => fail("expected Same(DoubleLit, [])")
  }
}

///|
test "Repr is readonly but constructible via smart ctors" {
  let info = @repr.Repr::ctor("X", [@repr.Repr::int_lit(1)])
  match info {
    @repr.Repr::Ctor("X", [@repr.Repr::IntLit(1)]) => ()
    _ => fail("expected Ctor(\"X\", [IntLit(1)])")
  }
  assert_eq(@repr.Repr::children(info).length(), 1)
  match @repr.Repr::shallow(info) {
    @repr.Repr::Ctor("X", []) => ()
    _ => fail("expected shallow Ctor(\"X\", [])")
  }
  match @repr.Repr::omitted() {
    @repr.Repr::Omitted => ()
    _ => fail("expected Omitted")
  }
}
