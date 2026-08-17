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

# Tool talks: search-based software engineering, 1976–2026

Pick one row from the table below. Your talk has three parts, in this
order:

1. **The application.** What SE task is being solved? Why is it hard?
   Who cares?
2. **The tool.** What algorithm drives it? Where did that algorithm
   come from, and what did the paper add to it?
3. **The value.** Was this the right tool for the task? What would a
   cheaper method (random search, a handful of labels, a simple
   heuristic) have delivered? Cite evidence, not vibes.

The table is sorted by the *birth date of the algorithm*, not the SE
paper — so you can watch the field move from local search, through
genetic algorithms and Pareto-based evolution, to active learning,
quantum circuits, and LLM hybrids. The middle of the table follows
[Ramírez, Romero & Ventura's 2019 survey of many-objective
SBSE](https://doi.org/10.1016/j.jss.2018.12.015); the ends extend it
backwards to 1976 and forwards to 2026.

## Topics

| # | Algorithm (born) | SE application | Paper |
|---|------------------|----------------|-------|
| <a name="ds"></a>1 | Numerical / direct search (1960s) | Test-data generation — the founding SBSE paper | [Miller & Spooner, TSE 1976](https://doi.org/10.1109/tse.1976.233818) |
| 2 | Local search, dynamic (gradient-style) | Test-data generation for paths | [Korel, TSE 1990](https://doi.org/10.1109/32.57624) |
| <a name="hc"></a>3 | Hill climbing | Software modularisation (Bunch) | [Mancoridis et al., IWPC 1998](https://doi.org/10.1109/wpc.1998.693283); [Mitchell & Mancoridis, TSE 2006](https://doi.org/10.1109/tse.2006.31) |
| 4 | [Genetic algorithms (Holland 1975)](https://doi.org/10.7551/mitpress/1090.001.0001) | Next release problem | [Bagnall et al., IST 2001](https://doi.org/10.1016/s0950-5849(01)00194-x) |
| 5 | Genetic algorithms | Project scheduling | [Alba & Chicano, Inf. Sci. 2007](https://doi.org/10.1016/j.ins.2006.12.020) |
| 6 | Genetic algorithms + greedy | Regression test prioritisation | [Li, Harman & Hierons, TSE 2007](https://doi.org/10.1109/tse.2007.38) |
| <a name="ga"></a>7 | Genetic algorithms (whole-suite) | Unit test generation (EvoSuite) | [Fraser & Arcuri, ESEC/FSE 2011](https://doi.org/10.1145/2025113.2025179) |
| <a name="sa"></a>8 | [Simulated annealing (Kirkpatrick et al. 1983)](https://doi.org/10.1126/science.220.4598.671) | Search-based maintenance / refactoring | [O'Keeffe & Ó Cinnéide, CSMR 2006](https://doi.org/10.1109/csmr.2006.49) |
| 9 | [Genetic programming (Koza 1992)](https://doi.org/10.1007/bf00175355) | Effort / size estimation | [Dolado, TSE 2000](https://doi.org/10.1109/32.879821) |
| <a name="gp"></a>10 | Genetic programming | Automated program repair (GenProg) | [Weimer et al., ICSE 2009](https://doi.org/10.1109/icse.2009.5070536) |
| <a name="nsga2"></a>11 | [NSGA-II (Deb et al. 2002)](https://doi.org/10.1109/4235.996017) | Pareto test-suite minimisation | [Yoo & Harman, ISSTA 2007](https://doi.org/10.1145/1273463.1273483) |
| 12 | Two-Archive / NSGA-II | Multi-objective module clustering | [Praditwong, Harman & Yao, TSE 2011](https://doi.org/10.1109/tse.2010.26) |
| 13 | NSGA-II | Bug-fix staffing: short- vs long-term | [Khalil et al., SSBSE 2017](https://doi.org/10.1007/978-3-319-66299-2_9) |
| 14 | NSGA-II + GP | Program repair, multi-objective (ARJA) | [Yuan & Banzhaf, TSE 2020](https://arxiv.org/abs/1712.07804) |
| 15 | NSGA-II | Simulation-based CPS test selection | [Arrieta et al., IST 2019](https://doi.org/10.1016/j.infsof.2019.06.009) |
| 16 | NSGA-II | Microservice extraction from legacy code | [Zhang et al., ICSA 2020](https://doi.org/10.1109/icsa47634.2020.00021) |
| 17 | Multi-objective search, meets practitioners | Do maintainers accept auto-generated microservice architectures? (industrial case study) | [Carvalho, Colanzi et al., TSE 2024](https://doi.org/10.1109/tse.2024.3361209) |
| <a name="nov"></a>18 | NSGA-II + [novelty search (Lehman & Stanley 2011)](https://doi.org/10.1162/evco_a_00025) | DNN behaviour-frontier testing (DeepJanus) | [Riccio & Tonella, ESEC/FSE 2020](https://doi.org/10.1145/3368089.3409730) |
| 19 | NSGA-II (dynamic, EMOOD) | Autonomous-driving requirements violations | [Luo et al., ASE 2021](https://doi.org/10.1109/ase51524.2021.9678883) |
| 20 | Possibilistic EA (NSGA-II lineage) | Code-smell detection under uncertainty | [Boutaib et al., EMSE 2022](https://doi.org/10.1007/s10664-022-10142-5) |
| 21 | Multi-objective search | ML fairness + accuracy repair | [Hort et al., EMSE 2023](https://doi.org/10.1007/s10664-023-10419-3) |
| <a name="ibea"></a>22 | [IBEA (Zitzler & Künzli 2004)](https://doi.org/10.1007/978-3-540-30217-9_84) | SPL feature selection, 5 objectives | [Sayyad, Menzies & Ammar, ICSE 2013](https://doi.org/10.1109/icse.2013.6606595) |
| <a name="moead"></a>23 | [MOEA/D (Zhang & Li 2007)](https://doi.org/10.1109/tevc.2007.892759) | Multi-objective regression testing | [Zheng et al., Inf. Sci. 2016](https://doi.org/10.1016/j.ins.2015.11.027) |
| 24 | MOEA/D (resource-constrained) | SPL feature selection at scale | [Xiang et al., EMO 2021](https://doi.org/10.1007/978-3-030-72062-9_52) |
| 25 | Proactive-rescheduling MOEA | Dynamic project scheduling | [Shen, Minku & Yao, TSE 2016](https://doi.org/10.1109/tse.2015.2512266) |
| <a name="al"></a>26 | [Active learning (Settles 2009)](https://burrsettles.com/pub/settles.activelearning.pdf) + clustering | Cheap config/model optimisation (GALE) | [Krall et al., TSE 2015](https://doi.org/10.1109/tse.2015.2432024) |
| <a name="sway"></a>27 | Recursive random projection (SWAY) | Sampling as a baseline optimizer | [Chen et al., TSE 2019](https://doi.org/10.1109/tse.2018.2790925) |
| 28 | Genetic improvement (GP lineage) | Non-functional properties: time, memory, energy | [Blot & Petke, CSUR 2025](https://doi.org/10.1145/3711119) |
| <a name="nsga3"></a>29 | [NSGA-III (Deb & Jain 2014)](https://doi.org/10.1109/tevc.2013.2281535) | Refactoring with 15 objectives | [Mkaouer et al., GECCO 2014](https://doi.org/10.1145/2576768.2598366) |
| 30 | NSGA-III | Model-transformation modularisation (MDE) | [Fleck et al., TSE 2017](https://doi.org/10.1109/tse.2017.2654255) |
| 31 | Many-objective EA | Test-database generation for SQL | [Ren et al., PPSN 2020](https://doi.org/10.1007/978-3-030-58115-2_16) |
| <a name="qaoa"></a>32 | [QAOA (Farhi et al. 2014)](https://arxiv.org/abs/1411.4028) | Quantum test-case optimisation | [Wang, Ali, Yue & Arcaini, TSE 2024](https://doi.org/10.1109/tse.2024.3479421) |
| <a name="mosa"></a>33 | MOSA / DynaMOSA | Unit test generation, many-objective | [Panichella, Kifetew & Tonella, TSE 2018](https://doi.org/10.1109/tse.2017.2663435) |
| 34 | MIO (many independent objectives) | REST/GraphQL/RPC API fuzzing (EvoMaster) | [Arcuri, IST 2018](https://doi.org/10.1016/j.infsof.2018.05.003); [tool report, ASE J. 2024](https://doi.org/10.1007/s10515-024-00478-1) |
| 35 | Exact assignment + LLM cost model | Routing queries across LLMs (OptLLM) | [Liu et al., ICWS 2024](https://doi.org/10.1109/icws62655.2024.00098) |
| 36 | ILP / exact formulations, revisited | Next release problem, generalised | [del Águila et al., 2025](https://arxiv.org/abs/2502.08139) |
| 37 | LLM-driven search | Testing LLM applications (STELLAR) | [Sorokin et al., 2026](https://arxiv.org/abs/2601.00497) |
| <a name="port"></a>38 | Portfolio: 20 optimizers, budget-aware | Which optimizer, at what budget? (106 SE tasks) | [Ganguly & Menzies, 2026](https://arxiv.org/abs/2607.11705) |
| <a name="llm"></a>39 | Classical-then-LLM hybrid (SNAP2) | SE configuration optimisation: seed the LLM with cheap classical search | [Srinivasan & Menzies, 2026](https://arxiv.org/abs/2607.02583) |

## One map of all these technologies

A repertory grid over the optimizers in the table: 10 bipolar
constructs, each tool rated 1 (left pole) to 5 (right pole), rows
and columns clustered so similar tools and similar distinctions sit
together. Note the four families the element dendrogram finds:
exact+local search; the evolutionary/Pareto bloc; the costly
LLM/quantum newcomers; and the frugal model-builders (active
learning, random projections) — which are *not* a small flavor of
the evolutionary family. Ratings are judgments: argue them in class.
Regenerate with `python3 etc/repgrid.py`.

<img src="https://raw.githubusercontent.com/txt/seai26f/refs/heads/main/etc/img/repgrid.png">

## Data for your experiments

Most rows can be re-run, or at least sanity-checked, against
[MOOT](https://github.com/timm/moot): 100+ SE multi-objective
optimisation tasks (configuration, effort, process, cloud tuning)
in one csv format. Rows 38–39 were benchmarked on it. If your talk
ends with "and here is that tool's idea, tried on a MOOT task",
you have earned the value discussion.

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
