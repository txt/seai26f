A common pattern is a big surface language for humans and a tiny **core** for the
optimizer and backend, with some called "desugaring" (or some similar name) as the bridge. 

Other names for "desugraing"
include
**tocore**, **lowering**, **elaboration**, or **macro expansion**.

| Language | Where / what it's called | Examples of what gets removed |
|---|---|---|
| **Haskell** (GHC) | Desugarer (`GHC.HsToCore`), typed `HsSyn` → Core (System FC), *after* typechecking | `do`, list comprehensions, guards, `where`, nested patterns → `case`, type classes → dictionary passing |
| **Scala 2 / 3** | Parser-time desugaring (`Desugar.scala` in Dotty), later "erasure" and "lambdalift" phases | `for` comprehensions → `map`/`flatMap`/`withFilter` |
| **Rust** | AST → HIR "lowering" (rustc literally tags spans with `DesugaringKind`) | `for` → `loop` + `match` on `IntoIterator`; `?` → `match`; `async` → generators |
| **Java** (javac) | `Lower` and `TransTypes` phases | inner classes, enhanced `for`, enums, autoboxing, generics erasure |
| **C#** (Roslyn) | "Lowering" (`LocalRewriter`) | `foreach`, `using`, `lock`, iterators and `async` → state machines |
| **Kotlin** | IR "lowering" passes (dozens of them) | coroutines, default args, data classes |
| **OCaml** | Typedtree → Lambda (`translcore`) | pattern matching → decision trees, objects/modules → records |
| **Scheme / Racket** | Macro expansion to "fully expanded" core forms | `let`, `cond`, `and`/`or` → `lambda`/`if` |
| **Clojure / Lisp** | `macroexpand` | `->`, `when`, `defn` |
| **Lean / Coq / Idris / Agda** | "Elaboration" to a small kernel calculus | `do`, implicit args, type classes, tactics |
| **Swift** | SILGen (AST → SIL) | `guard`, optionals chaining, `defer` |
| **C++** | Historically `cfront` (C++ → C); Clang keeps a desugared form inside `CXXForRangeStmt` | range-`for`, constructors/destructors |

