# Legacy debug deriving tool

This package is withdrawn in favor of the compiler's built-in `derive(Debug)`
and `moonbitlang/core/debug`. New code should use those standard facilities.
This repository retains the legacy generator for compatibility testing; the
withdrawn module is not being republished.

For existing projects, install the checked-out tool from the repository root:

```sh
moon install ./debug_deriving
```

With the installation directory on `PATH`, run:

```sh
debug_deriving input.mbt output.mbt
```

The input types marked `#debug.derive` receive implementations of the legacy
`moonbit-community/debug.Debug` trait. Public types also receive an explicit
`debug` method extension, preserving the old generated API on current compilers.
The two sibling example modules demonstrate registry and local source library
dependencies. `../check.sh` installs the tool into a temporary directory and
checks the library, generator, and both examples without using `bin-deps`.
