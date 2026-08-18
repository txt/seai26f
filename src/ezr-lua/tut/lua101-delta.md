# lua101.md delta — notes for the next rewrite

What the Aug 17 2026 lecture said about Lua that lua101.md does
not. Source: Panopto transcript.

- "Lua is Lisp without brackets." Every function is an
  unrestricted lambda body — no Python-style one-expression
  straitjacket. Add to the first-class-functions discussion.
- "My code has no inheritance, only polymorphism": one shared
  metatable per class, and that is the whole object system. Say
  it plainly near A.4.
- Customizability: you can write your own `f` function to
  emulate f-strings (`f"..."` parses because of the
  one-string-argument rule). Also praise the pattern library:
  running a pattern across a megabyte of text is fast — one of
  Lua's highly optimized corners.
- Why seeds exist: debugging a stochastic algorithm needs
  replayable sequences — reset the seed, get the same stream.
  How PRNGs work in one line: mutate a number, emit part of it,
  repeat. (eg0 has the reset-and-replay mechanics; the
  debugging rationale belongs here.)
- Say plainly: `require` is Lua's `import`. And the two-modes
  rule for any file, Lua or Python: imported → sit quietly and
  define things; run as the driver → do something (Lua: the
  `go(eg)` guard; Python: `if __name__ == "__main__"`).
