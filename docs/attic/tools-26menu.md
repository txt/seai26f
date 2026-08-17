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
  <a href="https://discord.gg/uQgTnGsfR"><img 
      src="https://img.shields.io/badge/Chat-%23008080?style=flat-square&logo=discord&logoColor=white" /></a>
  <a href="https://github.com/txt/seai26f/blob/main/LICENSE.md"><img 
      src="https://img.shields.io/badge/©%20timm%202026-%234b4b4b?style=flat-square&logoColor=white" /></a></p>
<h1 align="center">:cyclone: CSC491/591: SE for AI <br>NC State, Fall '26</h1>
<img src="https://raw.githubusercontent.com/txt/seai26f/refs/heads/main/etc/img/seai26f.png">

# Tools to Explore (for tool talks)

Each group signs up for **one** tool for its *tool talk* (see the schedule on
the [README](https://github.com/txt/seai26f/blob/main/README.md)).
One tool per group; first come, first served on the
[signup sheet](https://docs.google.com/spreadsheets/d/1EsVadqssyJXaQPFjTVEfOs3Uv8DOQ0WyNlgTMcsoeBo/edit).

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

| # | Tool | Year | Assumption | Notes | Example SE use |
|--:|------|------|:----:|-------|----------------|
| 1 | Random Search | 1950s | floor | baseline sanity check; surprisingly strong in high dimensions; blind probing | baseline for hyper-parameter tuning [38]; matched far heavier search in SBSE [36] |
| 2 | Hill Climbing | 1950s | A1 | local improvement, greedy trajectory; easily trapped in local optima | search-based test generation, local vs global search [9]; real-time API recommendation (Pyart) [11] |
| 3 | Genetic Algorithms (GA) | 1975 | A3 | evolutionary search using selection, crossover, mutation | automatic program repair (GenProg) [24]; multi-objective release planning [25] |
| 4 | (1+1) Evolution Strategy | 1973 | A1 | single incumbent, self-adaptive Gaussian step (1/5 rule) | many-independent-objective (MIO) test-suite generation [16] |
| 5 | Simulated Annealing (SA) | 1983 | A1 | probabilistic escape from local optima via temperature | search-based fault localization [14]; SBSE surveys [13] |
| 6 | Tabu Search | 1986 | A2 | memory-based search to avoid cycling | structural software testing [20]; cross-company defect-prediction transfer [21] |
| 7 | Iterated Local Search (ILS) | 2003 | A2 | restart escape: kick incumbent to new region, re-optimize | software project scheduling [18] |
| 8 | Genetic Programming (GP) | 1992 | A3 | evolves programs or parse trees | automatic patch evolution in GenProg [24][74] |
| 9 | Ant Colony Optimization (ACO) | 1992 | A3 | pheromone-based path exploration | test sequence/test data generation, first by McMinn & Holcombe 2003; 21+ testing studies surveyed by Suri & Singhal 2012 |
| 10 | Particle Swarm Optimization (PSO) | 1995 | A3 | flocking-based continuous optimization; velocity swarm | seed scheduling for greybox fuzzing [29] |
| 11 | MaxWalkSat | 1996 | A2 | greedy + random walk SAT solver | finding robust solutions in NASA requirements models (Gay, Menzies et al., ASE J 2010) |
| 12 | EDA (estimation of distribution) | 1996 | A3 | replaces crossover with a probability model fit to the best-so-far | test generation for mutation testing [27] |
| 13 | Differential Evolution (DE) | 1997 | A3 | vector-based evolutionary optimization; tournament winner at large budgets | tuning learners for SE text mining ("easy over hard") [31] |
| 14 | SPEA2 | 2001 | A4 | strength-based multi-objective optimization, external archive | multi-objective mutation testing of feature models [41] |
| 15 | NSGA-II | 2002 | A4 | non-dominated sorting with crowding distance; widely recommended, needs many evals | many-objective software remodularization [40]; feature-model testing [41] |
| 16 | IBEA | 2004 | A4 | indicator-based multi-objective optimization | software product-line configuration with user preferences (Sayyad et al., ICSE 2013 [48]) |
| 17 | SMS-EMOA | 2007 | A4 | hypervolume-contribution selection | Pareto-based feature selection for defect prediction [44] |
| 18 | MOEA/D | 2007 | A4 | decomposes MOO into scalar subproblems | compared on software remodularization [40] |
| 19 | Gaussian Process Models (GPM) | 2010s | A5 | probabilistic surrogates for expensive functions | Bayesian compiler autotuning [35]; DBMS knob tuning (OtterTune) [47] |
| 20 | SMAC / SMBO | 2011 | A5 | sequential surrogate-based optimization; random-forest surrogate handles categorical spaces | software configuration tuning [3][33] |
| 21 | TPE | 2011 | A5 | Bayesian optimization via density estimation of good vs ordinary configs | efficient compiler autotuning (BOCA) [35] |
| 22 | FLASH | 2017 | A5 | CART-based SMBO for SE configuration | finding faster software configurations [7] |
| 23 | SWAY | 2016 | A7 | recursive median-distance bisection down to a few representatives | "sampling" as baseline SBSE optimizer [36]; surrogate-accuracy study [37] |
| 24 | DODGE | 2019 | A7 | epsilon-pruning: discard configs falling in same epsilon-bin | tuning defect prediction and text mining pipelines [22] |
| 25 | LINE (kpp) | 2026 | A7 | centroid sampling (k-means++ style) from budget | data-light SE optimization [33][1] |
| 26 | EZR | 2026 | A7 | distance-based proximity active learning; tournament winner at tight budgets | explainable minimal-data optimization [1][33] |

## Selected references (from arXiv:2607.11705 bibliography)

- [1] A. Rayegan and T. Menzies, "Minimal data, maximum clarity: A heuristic for explaining optimization," *Journal of Systems and Software*, 2026.
- [3] P. Chen and T. Chen, "Promisetune: Unveiling causally promising and explainable configuration tuning," *ICSE*, 2026.
- [7] V. Nair, Z. Yu, T. Menzies, N. Siegmund, and S. Apel, "Finding faster configurations using flash," *IEEE TSE*, 46(7):794–811, 2018.
- [8] S. Russell and P. Norvig, *Artificial Intelligence: A Modern Approach, 4/E*. Pearson, 2021.
- [9] M. Harman and P. McMinn, "A theoretical and empirical study of search-based testing: Local, global, and hybrid search," *IEEE TSE*, 36(2):226–247, 2009.
- [10] M. Harman, S. A. Mansouri, and Y. Zhang, "Search-based software engineering: Trends, techniques and applications," *ACM CSUR*, 45(1):1–61, 2012.
- [12] S. Kirkpatrick, C. D. Gelatt Jr, and M. P. Vecchi, "Optimization by simulated annealing," *Science*, 220:671–680, 1983.
- [15] I. Rechenberg, *Evolutionsstrategie*. 1973.
- [17] H. R. Lourenço, O. C. Martin, and T. Stützle, "Iterated local search," in *Handbook of Metaheuristics*. Springer, 2003.
- [19] F. Glover, "Tabu search—part i," *ORSA Journal on Computing*, 1(3):190–206, 1989.
- [22] A. Agrawal, W. Fu, D. Chen, X. Shen, and T. Menzies, "How to 'dodge' complex software analytics," *IEEE TSE*, 47(10):2182–2194, 2019.
- [23] J. H. Holland, *Adaptation in Natural and Artificial Systems*. MIT Press, 1992.
- [24] C. Le Goues, T. Nguyen, S. Forrest, and W. Weimer, "Genprog: A generic method for automatic software repair," *IEEE TSE*, 38(1):54–72, 2011.
- [26] H. Mühlenbein and G. Paass, "From recombination of genes to the estimation of distributions i," *PPSN*, 1996.
- [28] J. Kennedy and R. Eberhart, "Particle swarm optimization," *ICNN'95*, 1995.
- [30] R. Storn and K. Price, "Differential evolution—a simple and efficient heuristic for global optimization over continuous spaces," *J. Global Optimization*, 11:341–359, 1997.
- [32] F. Hutter, H. H. Hoos, and K. Leyton-Brown, "Sequential model-based optimization for general algorithm configuration," *LION*, 2011.
- [33] K. K. Ganguly and T. Menzies, "How low can you go? the data-light SE challenge," *FSE*, 2026.
- [34] J. Bergstra, R. Bardenet, Y. Bengio, and B. Kégl, "Algorithms for hyper-parameter optimization," *NeurIPS*, 2011.
- [36] J. Chen, V. Nair, R. Krishna, and T. Menzies, "'Sampling' as a baseline optimizer for search-based software engineering," *IEEE TSE*, 46(6):597–614, 2018.
- [38] J. Bergstra and Y. Bengio, "Random search for hyper-parameter optimization," *JMLR*, 13(1):281–305, 2012.
- [39] K. Deb, A. Pratap, S. Agarwal, and T. Meyarivan, "A fast and elitist multiobjective genetic algorithm: Nsga-ii," *IEEE Trans. Evol. Comput.*, 6(2):182–197, 2002.
- [42] E. Zitzler, M. Laumanns, and L. Thiele, "Spea2: Improving the strength pareto evolutionary algorithm," *TIK report*, 103, 2001.
- [43] N. Beume, B. Naujoks, and M. Emmerich, "Sms-emoa: Multiobjective selection based on dominated hypervolume," *EJOR*, 181(3):1653–1669, 2007.
- [45] Q. Zhang and H. Li, "Moea/d: A multiobjective evolutionary algorithm based on decomposition," *IEEE Trans. Evol. Comput.*, 11(6):712–731, 2007.
- [74] J. R. Koza, "Genetic programming as a means for programming computers by natural selection," *Statistics and Computing*, 4:87–112, 1994.
- [37] P. Chen, J. Gong, and T. Chen, "Accuracy can lie: On the impact of surrogate model in configuration tuning," *IEEE TSE*, 51(2):548–580, 2025.
- [40] W. Mkaouer et al., "Many-objective software remodularization using nsga-iii," *ACM TOSEM*, 24(3):1–45, 2015.
- [41] R. A. Matnei Filho and S. R. Vergilio, "A multi-objective test data generation approach for mutation testing of feature models," *J. Softw. Eng. Res. Dev.*, 4(1):4, 2016.
- [44] C. Ni, X. Chen, F. Wu, Y. Shen, and Q. Gu, "An empirical study on pareto based multi-objective feature selection for software defect prediction," *J. Syst. Softw.*, 152:215–238, 2019.
- [47] D. Van Aken, A. Pavlo, G. J. Gordon, and B. Zhang, "Automatic database management system tuning through large-scale machine learning," *SIGMOD*, 2017.
- [48] A. S. Sayyad, T. Menzies, and H. Ammar, "On the value of user preferences in search-based software engineering: A case study in software product lines," *ICSE*, 2013.
- P. McMinn and M. Holcombe, early ACO for state-based test sequence generation, 2003 (first ACO-in-testing per later surveys).
- H. Suri and S. Singhal, "Literature survey of ant colony optimization in software testing," *CSI* 2012 (21 ACO-in-testing studies).
- G. Gay, T. Menzies, M. Jalali, et al., "Finding robust solutions in requirements models," *Automated Software Engineering*, 17:439–468, 2010 (MaxWalkSat on NASA requirements models).
- Non-tournament classics: M. Dorigo, *Optimization, Learning and Natural Algorithms*, PhD thesis, 1992; H. Kautz and B. Selman, "Pushing the envelope: planning, propositional logic, and stochastic search," *AAAI*, 1996; E. Zitzler and S. Künzli, "Indicator-based selection in multiobjective search," *PPSN*, 2004; C. E. Rasmussen and C. K. I. Williams, *Gaussian Processes for Machine Learning*, MIT Press, 2006.

