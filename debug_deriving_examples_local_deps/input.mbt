///|
#debug.derive
priv struct Pos {
  x : Int32
  y : String
  z : Double?
}

///|
/// Test pub type - should generate pub impl
#debug.derive
pub struct PubPoint {
  x : Int32
  y : Int32
}

///|
/// Test pub(all) type - should generate pub impl
#debug.derive
pub(all) struct PubAllPoint {
  x : Int32
  y : Int32
}

///|
#debug.derive
priv enum Lambda {
  Var(String)
  Lam(String, ty~ : String?, Lambda)
  App(Lambda, Lambda)
}

///|
#debug.derive
priv struct Pair(Int32, Bool)

///|
#debug.derive
priv suberror KeyNotFound {
  KeyNotFound((String, SourceLoc))
}

///|
let loc : SourceLoc = get_loc()

///|
#callsite(autofill(x))
fn get_loc(x~ : SourceLoc) -> SourceLoc {
  x
}

///|
#debug.derive
struct Stack[T] {
  array : Array[T]
  mut current : Int32
} derive(Default)

///|
pub fn[T] Stack::push(self : Self[T], x : T) -> Unit {
  self.array.push(x)
  self.current += 1
}

///|
test {
  let point = PubPoint::{ x: 1, y: 2, }
  inspect(@debug.pretty_print(point), content="{ x: 1, y: 2 }")
  inspect(
    @debug.pretty_print(PubAllPoint::{ x: 3, y: 4, }),
    content="{ x: 3, y: 4 }",
  )
  inspect(
    @debug.pretty_print(KeyNotFound(("key1", loc))),
    content=(
      #|KeyNotFound(("key1", <SourceLoc: "input.mbt:44:23-44:32@username/example">))
    ),
  )
  inspect(
    @debug.pretty_print({ x: 10, y: "20\n00", z: None, }),
    content=(
      #|{ x: 10, y: "20\n00", z: None }
    ),
  )
  inspect(
    @debug.pretty_print({ x: 10, y: "20\n00", z: Some(3.14), }),
    content=(
      #|{ x: 10, y: "20\n00", z: Some(3.14) }
    ),
  )
  inspect(@debug.pretty_print(Pair(10, false)), content="Pair(10, false)")
  let nested = Lambda::App(Lam("x", ty=Some("Int"), Var("x")), Var("y"))
  inspect(
    @debug.pretty_print(nested),
    content=(
      #|App(Lam("x", ty=Some("Int"), Var("x")), Var("y"))
    ),
  )
  let stack : Stack[Int32] = Default::default()
  stack..push(1)..push(2).push(3)
  inspect(
    @debug.pretty_print(stack),
    content="{ array: [1, 2, 3], current: 3 }",
  )
}

///|
pub extend Stack with Default::{default}
