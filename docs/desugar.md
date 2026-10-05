<p align="center">
  <a href="https://github.com/txt/seai26f/blob/main/README.md"><img 
     src="https://img.shields.io/badge/Home-%23ff5733?style=flat-square&logo=home&logoColor=white" /></a>
  <a href="https://github.com/txt/seai26f/blob/main/docs/lect/policies.md"><img 
      src="https://img.shields.io/badge/Policies-%230055ff?style=flat-square&logo=openai&logoColor=white" /></a>
  <a href="#"><img
      src="https://img.shields.io/badge/Teams-%23ffd700?style=flat-square&logo=users&logoColor=white" /></a>
  <a href="https://moodle-courses2527.wolfware.ncsu.edu/course/view.php?id=11951&bp=s"><img 
      src="https://img.shields.io/badge/491%20Moodle-%23dc143c?style=flat-square&logo=moodle&logoColor=white" /></a>
  <a href="https://moodle-courses2527.wolfware.ncsu.edu/course/view.php?id=13665&bp=sfroge"><img 
      src="https://img.shields.io/badge/591%20Moodle-%23f98012?style=flat-square&logo=moodle&logoColor=white" /></a>
  <a href="https://ncsu.hosted.panopto.com/Panopto/Pages/Sessions/List.aspx#folderID=a8560b36-2071-4a70-8c3a-b4a4017e9ff5"><img 
      src="https://img.shields.io/badge/Recordings-%236f42c1?style=flat-square&logo=youtube&logoColor=white" /></a>
  <a href="https://discord.gg/uQgTnGsfR"><img 
      src="https://img.shields.io/badge/Chat-%23008080?style=flat-square&logo=discord&logoColor=white" /></a>
  <a href="https://github.com/txt/seai26f/blob/main/LICENSE.md"><img 
      src="https://img.shields.io/badge/©%20timm%202026-%234b4b4b?style=flat-square&logoColor=white" /></a></p>
<h1 align="center">:cyclone: CSC491/591: SE for AI <br>NC State, Fall '26</h1>
<img src="https://raw.githubusercontent.com/txt/seai26f/refs/heads/main/etc/img/seai26f.png">

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

