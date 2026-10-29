///|
test "cmd/main: demo_output is stable" {
  let (a, b) = run_demo()
  inspect(
    a,
    content=(
      #|{ "a": 3, "b": 6, "c": 13 }
    ),
  )
  inspect(
    b,
    content="{ \"a\": 3, \"b\": \u{1b}[31m-6\u{1b}[0m \u{1b}[32m+9\u{1b}[0m, \"c\": 13 }",
  )
}
