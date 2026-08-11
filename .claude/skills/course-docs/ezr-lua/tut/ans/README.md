# tut/ans — exam answers

One file per lecture, `aN.md`, numbered to match that lecture's
"Exam questions" block. Release policy: answers ship one week behind
their questions — weave with `make tut.md RELEASED=k` to include
answers for lectures 1..k. Format per answer: (a) three lines max;
(b) the mistake, its consequence, the fix — plus, where the bug is
runnable, the harness-verified wrong output.
