<p align="center">
  <a href="https://github.com/txt/seai26f/blob/main/README.md"><img 
     src="https://img.shields.io/badge/Home-%23ff5733?style=flat-square&logo=home&logoColor=white" /></a>
  <a href="https://github.com/txt/seai26f/blob/main/docs/lect/policies.md"><img 
      src="https://img.shields.io/badge/Policies-%230055ff?style=flat-square&logo=openai&logoColor=white" /></a>
  <a href="#"><img
      src="https://img.shields.io/badge/Teams-%23ffd700?style=flat-square&logo=users&logoColor=white" /></a>
  <a href="https://moodle-courses2527.wolfware.ncsu.edu/course/view.php?id=11951&bp=s"><img 
      src="https://img.shields.io/badge/491%20Moodle-%23dc143c?style=flat-square&logo=moodle&logoColor=white" /></a>
  <a href="https://moodle-courses2527.wolfware.ncsu.edu/my/"><img 
      src="https://img.shields.io/badge/591%20Moodle-%23f98012?style=flat-square&logo=moodle&logoColor=white" /></a>
  <a href="https://discord.gg/uQgTnGsfR"><img 
      src="https://img.shields.io/badge/Chat-%23008080?style=flat-square&logo=discord&logoColor=white" /></a>
  <a href="https://github.com/txt/seai26f/blob/main/LICENSE.md"><img 
      src="https://img.shields.io/badge/©%20timm%202026-%234b4b4b?style=flat-square&logoColor=white" /></a></p>
<h1 align="center">:cyclone: CSC491/591: SE for AI <br>NC State, Fall '26</h1>
<img src="https://raw.githubusercontent.com/txt/seai26f/refs/heads/main/etc/img/seai26f.png">

# Tool talks: 16 topics, 1976–2026

Each group signs up for **one** topic below; one topic per group,
first come, first served on the
[signup sheet](https://docs.google.com/spreadsheets/d/1EsVadqssyJXaQPFjTVEfOs3Uv8DOQ0WyNlgTMcsoeBo/edit).
The schedule on the
[README](https://github.com/txt/seai26f/blob/main/README.md) assigns
each topic its night (the tool:xx cells link back to rows here), so
picking a topic also picks your talk date.

## The talk

Talks are 30 minutes long. Try to finish in 25 so we have 5
minutes for questions.

A tool talk explores one line of the table below:

- presents the SE problem (important! state this first!);
- reviews the tool algorithm;
- discusses how (if at all) the tool addressed the problem.

Important:

- Write the talk in Google Slides, public to everyone, editable
  by timm@ieee.org.
- Discuss the talk with the lecturer the week before, so they
  can fill in any missing theory stuff.

## Rubric (15 marks)

| Marks | For | Check |
|------:|-----|-------|
| 3 | **The problem**: the SE problem, stated first | a stranger could say why anyone cares |
| 3 | **The algorithm**: how the tool works | key idea in your own words, not vendor prose |
| 3 | **The verdict**: did the tool address the problem? | evidence shown; "no" with reasons scores full |
| 2 | **Discussed with lecturer the week before** | no discussion = 0 |
| 2 | **Timing**: done in 25, left 5 minutes for questions | running past 30 = 0 |
| 2 | **Slides + delivery**: Google Slides public and editable by timm@ieee.org; in person, whole group on stage | |

Ways to lose marks: problem stated last (or never); no verdict,
just a feature tour; no time left for questions; slides the
lecturer cannot open.

## Topics

Sixteen topics, one per distinct technology, sorted by the *birth
date of the algorithm* (not the SE paper) — so the semester walks
the field from direct search, through genetic algorithms and
Pareto-based evolution, to active learning, quantum circuits, and
LLM hybrids. The middle rows follow [Ramírez, Romero & Ventura's
2019 survey of many-objective
SBSE](https://doi.org/10.1016/j.jss.2018.12.015); the ends extend
it backwards to 1976 and forwards to 2026. (A longer, unpruned
list sits in
[the attic](https://github.com/txt/seai26f/blob/main/docs/attic/topics.md).)

| tag | Algorithm (born) | SE application | Paper |
|-----|------------------|----------------|-------|
| <a name="ds"></a>tool:ds | Numerical / direct search (1960s) | Test-data generation — the founding SBSE paper | [Miller & Spooner, TSE 1976](https://doi.org/10.1109/tse.1976.233818) |
| <a name="hc"></a>tool:hc | Hill climbing | Software modularisation (Bunch) | [Mancoridis et al., IWPC 1998](https://doi.org/10.1109/wpc.1998.693283); [Mitchell & Mancoridis, TSE 2006](https://doi.org/10.1109/tse.2006.31) |
| <a name="ga"></a>tool:ga | [Genetic algorithms (Holland 1975)](https://doi.org/10.7551/mitpress/1090.001.0001) | Unit test generation (EvoSuite) | [Fraser & Arcuri, ESEC/FSE 2011](https://doi.org/10.1145/2025113.2025179) |
| <a name="sa"></a>tool:sa | [Simulated annealing (Kirkpatrick et al. 1983)](https://doi.org/10.1126/science.220.4598.671) | Search-based maintenance / refactoring | [O'Keeffe & Ó Cinnéide, CSMR 2006](https://doi.org/10.1109/csmr.2006.49) |
| <a name="gp"></a>tool:gp | [Genetic programming (Koza 1992)](https://doi.org/10.1007/bf00175355) | Automated program repair (GenProg) | [Weimer et al., ICSE 2009](https://doi.org/10.1109/icse.2009.5070536) |
| <a name="nsga2"></a>tool:nsga2 | [NSGA-II (Deb et al. 2002)](https://doi.org/10.1109/4235.996017) | Pareto test-suite minimisation | [Yoo & Harman, ISSTA 2007](https://doi.org/10.1145/1273463.1273483) |
| <a name="nov"></a>tool:nov | NSGA-II + [novelty search (Lehman & Stanley 2011)](https://doi.org/10.1162/evco_a_00025) | DNN behaviour-frontier testing (DeepJanus) | [Riccio & Tonella, ESEC/FSE 2020](https://doi.org/10.1145/3368089.3409730) |
| <a name="ibea"></a>tool:ibea | [IBEA (Zitzler & Künzli 2004)](https://doi.org/10.1007/978-3-540-30217-9_84) | SPL feature selection, 5 objectives | [Sayyad, Menzies & Ammar, ICSE 2013](https://doi.org/10.1109/icse.2013.6606595) |
| <a name="moead"></a>tool:moead | [MOEA/D (Zhang & Li 2007)](https://doi.org/10.1109/tevc.2007.892759) | Multi-objective regression testing | [Zheng et al., Inf. Sci. 2016](https://doi.org/10.1016/j.ins.2015.11.027) |
| <a name="al"></a>tool:al | [Active learning (Settles 2009)](https://burrsettles.com/pub/settles.activelearning.pdf) + clustering | Cheap config/model optimisation (GALE) | [Krall et al., TSE 2015](https://doi.org/10.1109/tse.2015.2432024) |
| <a name="sway"></a>tool:sway | Recursive random projection (SWAY) | Sampling as a baseline optimizer | [Chen et al., TSE 2019](https://doi.org/10.1109/tse.2018.2790925) |
| <a name="nsga3"></a>tool:nsga3 | [NSGA-III (Deb & Jain 2014)](https://doi.org/10.1109/tevc.2013.2281535) | Refactoring with 15 objectives | [Mkaouer et al., GECCO 2014](https://doi.org/10.1145/2576768.2598366) |
| <a name="qaoa"></a>tool:qaoa | [QAOA (Farhi et al. 2014)](https://arxiv.org/abs/1411.4028) | Quantum test-case optimisation | [Wang, Ali, Yue & Arcaini, TSE 2024](https://doi.org/10.1109/tse.2024.3479421) |
| <a name="mosa"></a>tool:mosa | MOSA / DynaMOSA | Unit test generation, many-objective | [Panichella, Kifetew & Tonella, TSE 2018](https://doi.org/10.1109/tse.2017.2663435) |
| <a name="port"></a>tool:port | Portfolio: 20 optimizers, budget-aware | Which optimizer, at what budget? (106 SE tasks) | [Ganguly & Menzies, 2026](https://arxiv.org/abs/2607.11705) |
| <a name="llm"></a>tool:llm | Classical-then-LLM hybrid (SNAP2) | SE configuration optimisation: seed the LLM with cheap classical search | [Srinivasan & Menzies, 2026](https://arxiv.org/abs/2607.02583) |

## Data for your experiments

Most rows can be re-run, or at least sanity-checked, against
[MOOT](https://github.com/timm/moot): 100+ SE multi-objective
optimisation tasks (configuration, effort, process, cloud tuning)
in one csv format. tool:port and tool:llm were benchmarked on it.
If your talk ends with "and here is that tool's idea, tried on a
MOOT task", you have earned the value discussion.

## Read these regardless of your row

- The manifesto: [Harman & Jones, *Search-based software
  engineering*, IST 2001](https://doi.org/10.1016/s0950-5849(01)00189-6)
- The testing survey: [McMinn, STVR 2004](https://doi.org/10.1002/stvr.294)
- The many-objective survey this list grew from:
  [Ramírez et al., JSS 2019](https://doi.org/10.1016/j.jss.2018.12.015)
- How to evaluate Pareto results:
  [Li, Chen & Yao, TSE 2022](https://doi.org/10.1109/tse.2020.3036108)
- Why weighted sums can mislead:
  [Chen & Li, TOSEM 2023](https://doi.org/10.1145/3514233)

Every link above resolves as of 2026-08-07 (checked against the DOI
handle registry and arXiv).
