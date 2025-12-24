///|
pub impl Debug for Int with debug(self) {
  Repr::int(self)
}

///|
pub impl Debug for Int64 with debug(self) {
  Repr::opaque_("Int64", [Repr::literal(self.to_string())])
}

///|
pub impl Debug for UInt with debug(self) {
  Repr::opaque_("UInt", [Repr::literal(self.to_string())])
}

///|
pub impl Debug for Double with debug(self) {
  Repr::double(self)
}

///|
pub impl Debug for Bool with debug(self) {
  Repr::bool(self)
}

///|
pub impl Debug for Char with debug(self) {
  Repr::char(self)
}

///|
pub impl Debug for String with debug(self) {
  Repr::string(self)
}

///|
pub impl Debug for Unit with debug(_) {
  Repr::tuple([])
}

///|
pub impl[T : Debug] Debug for Array[T] with debug(self) {
  Repr::array(self.map(fn(x) { debug(x) }))
}

///|
pub impl[T : Debug] Debug for T? with debug(self) {
  match self {
    None => Repr::ctor("None", [])
    Some(x) => Repr::ctor("Some", [(None, debug(x))])
  }
}

///|
pub impl[A : Debug, B : Debug] Debug for (A, B) with debug(self) {
  let (a, b) = self
  Repr::tuple([debug(a), debug(b)])
}

///|
pub impl[K : Debug, V : Debug] Debug for Map[K, V] with debug(self) {
  Repr::dict(
    self
    .to_array()
    .map(fn(kv) {
      let (k, v) = kv
      (debug(k), debug(v))
    }),
  )
}
