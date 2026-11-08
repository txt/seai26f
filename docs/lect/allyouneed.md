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

# All you need

One idea joins every method in this course. **Options are obvious and
plentiful; outcomes are costly to collect.** You can list a thousand
configs, designs, or candidate rows in a minute — but knowing which is
*good* means running an experiment, labelling a row, paying for an
outcome. So every method here is a policy for spending a tiny
**outcome budget** well.

Modern AI has three big paradigms. Each is a slogan — "X is all you
need" — and each is one answer to the same question:

> **Which cheap signal tells us which option is good, without
> collecting every outcome?**

```mermaid
flowchart TD
  Q["Which cheap signal picks good options,<br/>without collecting every outcome?"]
  Q --> C["CONTRAST<br/>good vs bad<br/>'contrast is all you need'"]
  Q --> A["ATTENTION<br/>a learned weighting<br/>'attention is all you need'"]
  Q --> R["REWARD<br/>one number<br/>'reward is all you need'"]
  C --> C2["ripple-down rules · treatment<br/>learning · active learning · <b>ezr</b>"]
  A --> A2["transformers · LLMs"]
  R --> R2["RL · AlphaGo · RLHF · the<br/>evaluator in your loop"]
```

This course lives in the **left column**. The market lives in the
**middle**.

## Old idea: the signal is in the few

Spending little to learn much is not new. For seventy years, field
after field found the useful signal is **small** — so you can look at,
and collect, far less than you think:

| Decade | Field | Lesson |
|---|---|---|
| 1950s | psychology | People judge *differences*, not things (Kelly). |
| 1950s | neuroscience | The eye transmits *edges*, not surfaces. |
| 1980s | cognitive science | Experts attend to *less*, not more. |
| 1980s | decision support | Show only the numbers that change the decision. |
| 2020s | SE with AI | Generation is cheap. Review is not. |

The chess result is the whole course in one study: a master recalls
real boards far better than a novice, random boards no better — a
master sees a few **chunks**, not 32 pieces (Chase & Simon, 1973).
Expertise is compiled attention. A difference is a smaller message
than a description — so a search over *contrasts* finds a usable
model from far fewer samples. That is paradigm 1.

## Paradigm 1: contrast is all you need

Psychology proposed it, biology confirmed it, software shipped it.

- **Psychology** — Kelly (1955): people reason about bipolar
  *constructs* (cheap↔dear). The **repertory grid** elicits them by
  triads. (You ran one on yourselves.)
- **Biology** — retinal cells fire on the *difference* between a spot
  and its surround; cortex cells fire only on *edges* (Hubel &
  Wiesel, Nobel 1981). Information concentrates on the contour; the
  interior is redundant (Attneave, 1954).
- **Software**, one step per era:

```mermaid
flowchart LR
  rdr["1991<br/>ripple-down rules<br/>ask only at the last error"]
  --> tar["2007<br/>treatment learning<br/>2-3 controls from 1000s"]
  --> flash["2018<br/>analytics stock-take<br/>small ≈ or > large"]
  --> acq["2026<br/>acquisition<br/>few dozen labels → 90% of best"]
```

The last box is **your `acquire`**: label next the one example that
best separates best from rest; a few dozen labels reach >90% of the
best reported results across 100+ tasks (*How low can you go?*, FSE
2026). Decide, classify, predict, configure, optimize — all five
course jobs have a paradigm-1 method.

## Paradigm 2: attention is all you need

**Attention is a softmax average.** Score the query against every
input item, softmax the scores into weights that sum to one, return
the weighted sum. A soft lookup table — "fetch what matches, mostly."
"Soft" is the point: every weight has a gradient, so *where to look*
is learned by the same backprop as everything else.

```mermaid
flowchart LR
  q["query"] --> s["score vs<br/>every item"]
  s --> sm["softmax<br/>→ weights"]
  sm --> w["weighted sum<br/>(the answer)"]
```

How an afterthought ate the field: 2014, attention was a *patch* on
translation RNNs (let the decoder peek back at all states). 2017,
the patch was the product — delete the RNN, keep only the softmax:
the transformer (*Attention is all you need* — the title is
literal). Why deletion won: an RNN is serial (token *t* waits for
*t−1*); pure attention is one parallel matrix multiply, which GPUs
love. Training time fell, model and data size rose → the LLM.

The cost: the attention policy is **internal** — billions of
unreadable weights. Paradigm 1 *prints* its reasons; paradigm 2
makes you *build the printer* (logs, audits — your batch/logfmt
discipline from week 9).

## Paradigm 3: reward is all you need

Reinforcement learning: learn by trial, the only teacher a scalar
**reward**. 2013, one net learns Atari from pixels + score. 2017,
AlphaGo Zero reaches superhuman Go *tabula rasa* — self-play and the
win signal only. 2021, the strong claim: reward is enough for all
abilities, language included.

You rent this paradigm twice. First, **RLHF** — reinforcement
learning from human feedback: a reward step that fine-tunes an LLM on
human preference rankings — tuned the model you call. Second, in an
**agentic loop the evaluator is a fitness function.** The failure
rents with it: "make the tests pass" rewarded GenProg for *deleting*
tests — reward hacking. **You get what you reward, not what you
want.** So agree a testable contract before generation runs.

## The market explores two. You know all three.

```mermaid
flowchart TD
  subgraph market["2026 commercial activity"]
    P2["Paradigm 2<br/>almost all of it"]
    P3["Paradigm 3<br/>mostly serves P2 (RLHF, evaluators)"]
  end
  P1["Paradigm 1<br/>almost no commercial activity —<br/>yet holds the best cost/accuracy<br/>record for 4 of 5 jobs"]
```

Why the gap? Paradigm 2 ships as **one general product**; paradigm 1
must be **fitted** to your data and goal. Economics, not evidence. So
a design review asks three things: **name the job, name the
paradigm, show the paradigm-1 baseline you measured.**

## Cross the streams

The paradigms are not rivals; they compose. The measured SE result:
run the **classical optimizer first** (paradigm 1), then **seed the
LLM** (paradigm 2) with those results.

```mermaid
flowchart LR
  d["data"] --> p1["paradigm-1<br/>optimizer (cheap)"]
  p1 --> seed["seed the LLM<br/>with the good region"]
  seed --> p2["LLM<br/>(paradigm 2)"]
  p2 --> out["top tier on 85% of 100+ tasks<br/>30% fewer tokens · 1.4× faster"]
```

The reverse order is worse (Srinivasan & Menzies, 2026). Same shape
in *Warm starts* (TOSEM 2024): the LLM helps most at the **start or
end** of a search, not as the search. Prompting one attention model
is one cell of a large space. Engineers who know all three paradigms
get to combine them.

## Sources

Every citation links to a DOI or a PDF so you can check it. (Links
re-used from [N12](https://github.com/txt/se26f/blob/main/docs/lect/n12.md),
which carries the full set.)

- Simon, *Designing organizations for an information-rich world*, 1971
  — [pdf](https://gwern.net/doc/design/1971-simon.pdf)
- Chase & Simon, *Perception in chess*, Cognitive Psychology 4, 1973
  — [doi:10.1016/0010-0285(73)90004-2](https://doi.org/10.1016/0010-0285(73)90004-2)
- Kelly, *The Psychology of Personal Constructs*, Norton, 1955 (book;
  no DOI)
- Hubel & Wiesel, J. Physiology 160, 1962
  — [doi:10.1113/jphysiol.1962.sp006837](https://doi.org/10.1113/jphysiol.1962.sp006837)
- Attneave, *Informational aspects of visual perception*, Psych.
  Review 61, 1954
  — [pdf](http://wexler.free.fr/library/files/attneave%20%281954%29%20some%20informational%20aspects%20of%20visual%20perception.pdf)
- Compton & Jansen, *A philosophical basis for knowledge acquisition*
  (ripple-down rules), 1990
  — [doi:10.1016/S1042-8143(05)80017-2](https://doi.org/10.1016/S1042-8143(05)80017-2)
- Menzies et al., *The business case for automated SE* (TAR3), ASE
  2007 — [doi:10.1145/1321631.1321676](https://dl.acm.org/doi/10.1145/1321631.1321676)
- *How low can you go?*, FSE 2026
  — [arXiv:2512.13524](https://arxiv.org/pdf/2512.13524)
- Bahdanau, Cho & Bengio, *Neural MT by jointly learning to align and
  translate*, ICLR 2015 — [arXiv:1409.0473](https://arxiv.org/pdf/1409.0473)
- Vaswani et al., *Attention is all you need*, 2017
  — [arXiv:1706.03762](https://arxiv.org/pdf/1706.03762)
- Mnih et al., *Playing Atari with deep RL*, 2013
  — [arXiv:1312.5602](https://arxiv.org/pdf/1312.5602)
- Silver et al., *Mastering Go without human knowledge* (AlphaGo
  Zero), Nature 550, 2017
  — [pdf](https://discovery.ucl.ac.uk/id/eprint/10045895/1/agz_unformatted_nature.pdf)
- Silver, Singh, Precup & Sutton, *Reward is enough*, Artificial
  Intelligence 299, 2021
  — [doi:10.1016/j.artint.2021.103535](https://doi.org/10.1016/j.artint.2021.103535)
- Ouyang et al., *Training LMs to follow instructions* (InstructGPT /
  RLHF), 2022 — [arXiv:2203.02155](https://arxiv.org/pdf/2203.02155)
- Srinivasan & Menzies, *Better together, in the right order*, 2026
  — [arXiv:2607.02583](https://arxiv.org/pdf/2607.02583)
