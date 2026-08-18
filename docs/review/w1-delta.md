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

# Review, week 1: the delta

Things said in lecture one that are not (yet) in the notes,
then questions on them. Answers at the bottom.

## The recap

**Three more rat tricks** (beyond the four in
[hello](https://txt.github.io/seai26f/hello.html)):

- **Active learning.** Do not learn from all the data. Build a
  tiny model, then use it to carefully select what to label
  next. That lets us ignore the uninformative, noisy, redundant
  data — in practice, most of the data. Active learners build
  competent models from a handful of labels (the ~50 from the
  maths) even across tens of thousands of variables. X values
  come free with every row; Y values cost a test drive.
- **Check the straw men.** Always baseline a sophisticated
  method against the dumbest possible one. Again and again the
  simple baseline is good enough, and the ceremony of the
  complex method was not worth it.
- **Exploit the repeated structure of SE data.** Software is
  written to be maintained by someone else, so it uses expected
  patterns — "natural" programs "are mostly simple and rather
  repetitive; thus they have usefully predictable statistical
  properties" ([the naturalness
  hypothesis](https://earlbarr.com/publications/naturalness_cacm.pdf)).
  That is why simple methods keep winning here.

**Two warnings:**

- **Bainbridge, Ironies of Automation (1983).** Automate the
  easy parts and humans keep the hard residue, plus a monitoring
  role they are cognitively bad at — about 30 minutes of useful
  attention. Watching a long Claude loop run is a Bainbridge
  situation.
- **Jevons paradox.** Cheaper coal burned more coal; the new
  expressway is the new traffic jam. Even if every bubble
  argument is wrong, cheap AI ends up scarce.

**Stochastic notes.** Random does not mean crazy: a random
variable comes from a known distribution with a mean and a
variance — structure you can exploit. Simulated annealing
escapes local maxima by sometimes accepting a worse solution.
PSO particles never stop, so the swarm re-converges when the
world changes: optimization as a maintenance model.

**The sampling ladder.** Reward-free reinforcement learning (a
car that must satisfy laws not yet written): ~10^15 samples.
Know the goal (best-arm, the biased slot machine): ~10^4.
Accept near-enough (Cohen + Hamlet): ~50. Reuse someone else's
model and binary-chop: ~6.

**The tree demo.** `lua ezr-eg.lua --show`, on 398 cars:

<img src="../tree-demo.png" width=500>

Row one is the baseline: the mean of every column over all 398
rows. ▲ marks the best leaf, ▼ the worst. Reading down a
branch, constraints accumulate (each `|` is one more AND);
each split holds about half its parent's rows. On a 5,000-row
configuration problem with 17 choices, three variables
controlled everything — thirty years of software analytics
says that is the norm: a few variables matter, the rest can be
ignored.

**Seeds.** Stochastic programs need replayable runs, for
debugging and for grading by diff. A pseudo-random generator
mutates a number and emits part of it, over and over; reset the
seed and the same stream returns.

## Questions

**D1.** An active learner builds a tiny model early. What is
that model used for? What happens to the rest of the data?

**D2.** In the used-car lot, which columns are cheap and which
are dear — X or Y? Why?

**D3.** "Check the straw men": what should every sophisticated
method be compared against, and what does that comparison
usually reveal?

**D4.** Why do simple methods keep winning on software
engineering data? (One phrase: the ______ hypothesis.)

**D5.** Bainbridge: if you automate the easy parts, what two
things are humans left with? Roughly how long can a human
usefully monitor? Why is watching a long agent loop a
Bainbridge situation?

**D6.** State the Jevons paradox. Why does it predict AI gets
expensive even if every bubble argument fails?

**D7.** What is the one question about junior programmers that
companies cannot answer?

**D8.** Order by samples needed, largest first: near-enough
random sampling; reward-free RL; binary chop over a borrowed
model; best-arm bandit. For each step down, what new knowledge
collapses the cost?

**D9.** How does simulated annealing escape a local maximum?

**D10.** Why is a never-stopping particle swarm a natural model
of maintenance?

**D11.** Name the two properties that make a random variable
exploitable rather than "crazy".

**D12.** In `--show` output, what does the first row report?

**D13.** What do the ▲ and ▼ marks flag?

**D14.** Reading down one branch of the tree, what accumulates?
Roughly how many rows does each split keep?

**D15.** 17 configuration choices, and the tree used three.
What is the thirty-year claim this illustrates?

**D16.** Why do stochastic programs need seeds at all? Resetting
the seed guarantees what?

**D17.** Why must the RNG port match the Lua output exactly,
when everything else is "near enough is good enough"?

**D18.** A Lua or Python file can be run two ways. Name them,
and say what the file should do in each. What line guards this
in Python? In this course's Lua?

**D19.** `python3 port.py --seed=42 rand` — list, in order, the
three things that happen before `test_rand` returns.

## Answers

**D1.** choosing the next thing to label; the uninformative,
noisy, redundant rest is ignored.
**D2.** X cheap (visible on every row), Y dear (each label
costs a test drive / a build / an expert's hour).
**D3.** the dumbest possible baseline; that the simple thing is
often good enough and the complex method's ceremony was not
worth it.
**D4.** the naturalness hypothesis: code is written to be
maintained, so it is repetitive, so it is statistically
predictable.
**D5.** the hard residue plus a monitoring role; ~30 minutes;
because you are a human monitoring an automated process you no
longer practice.
**D6.** cheaper means used more, which means congested and
expensive again; so even good cheap AI ends up scarce.
**D7.** "How will you find senior programmers in ten years if
you are not hiring and training junior ones?"
**D8.** reward-free RL (~10^15) > best-arm (~10^4) >
near-enough (~50) > binary chop (~6). Collapses: knowing the
goal; accepting near-enough (Cohen's 6% + Hamlet); borrowing a
model that ranks pairs (log2).
**D9.** with some probability it accepts a worse solution, so
it can climb out of holes.
**D10.** the particles keep moving, so when the world changes
the swarm re-converges — free maintenance.
**D11.** a known distribution, with a mean and a variance.
**D12.** the baseline: the mean of every column over all rows.
**D13.** the best (▲) and worst (▼) leaves, by distance to
heaven.
**D14.** constraints, ANDed one per level; each split keeps
about half its parent's rows.
**D15.** in any business problem a few variables matter and the
rest can be ignored.
**D16.** so random runs can be replayed exactly, for debugging
and grading; the same seed yields the same stream of numbers.
**D17.** because grading is diff: same seed must mean the SAME
20 numbers across Lua and Python.
**D18.** imported (sit quietly, only define things) vs run as
the driver (do something). Python: `if __name__ == "__main__"`.
Here: the `go(eg)` guard, which checks the file is `arg[0]`.
**D19.** the `--seed=42` flag updates `the.seed`;
`random.seed(the.seed)` resets the stream; the name `rand` is
looked up as `test_rand` and called.
