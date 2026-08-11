<a name="glossary"></a>
# Glossary

Each acronym appears in exactly one vignette, at its first executable
use; every later mention links here. Listed in discovery order:
the order the REPL first meets each idea.

| Acro                              | Expansion                        | One line                                                   | First use     | Ref              |
| --------------------------------- | -------------------------------- | ---------------------------------------------------------- | ------------- | ---------------- |
| <a name="g-seed"></a>SEED         | Reproducible randomness          | Fix the seed to replay a run; vary it to trust a claim     | [L1.1](#l1)   | Park-Miller 1988 |
| <a name="g-noir"></a>NOIR         | Nominal/Ordinal/Interval/Ratio   | Scales of measurement; symbol vs number here               | [L1.1](#l1)   | Stevens 1946     |
| <a name="g-wel"></a>WEL           | Welford's online variance        | Mean and variance in one pass, no stored data              | [L1.4](#l1)   | Welford 1962     |
| <a name="g-ent"></a>ENT           | Shannon entropy                  | A symbol column's spread, in bits                          | [L1.5](#l1)   | Shannon 1948     |
| <a name="g-cdf"></a>CDF           | Cumulative distribution          | Fraction of a population at or below a value               | [L1.6](#l1)   | —                |
| <a name="g-log"></a>LOG           | Logistic squashing               | Logistic approximates the normal CDF (±1%)                 | [L1.6](#l1)   | —                |
| <a name="g-role"></a>ROLE         | Feature vs goal                  | x-inputs and y-goals, split from the header                | [L2.2](#l2)   | —                |
| <a name="g-stream"></a>STREAM     | Subtractable summary             | Removing a datum costs the same as adding it               | [L2.4](#l2)   | Welford 1962     |
| <a name="g-mink"></a>MINK         | Minkowski distance               | p-norm family: p=1 Manhattan, p=2 Euclidean                | [L3.2](#l3)   | —                |
| <a name="g-d2h"></a>D2H           | Distance to heaven               | One 0..1 score: gap to the ideal on every goal             | [L3.3](#l3)   | —                |
| <a name="g-pareto"></a>PARETO     | Pareto optimality                | No other solution beats it on every goal                   | [L3.3](#l3)   | —                |
| <a name="g-pole"></a>POLE         | Far-pair poles                   | Project rows onto the line between two extremes            | [L4.1](#l4)   | Faloutsos 1995   |
| <a name="g-fastmap"></a>FASTMAP   | FastMap projection               | Place points by distance to two pivots                     | [L4.1](#l4)   | Faloutsos 1995   |
| <a name="g-halve"></a>HALVE       | Recursive bisection              | Split on the principal axis, recurse                       | [L4.3](#l4)   | —                |
| <a name="g-cut"></a>CUT           | Supervised discretization        | The threshold that most purifies an outcome                | [L5.1](#l5)   | Fayyad 1993      |
| <a name="g-ig"></a>IG             | Information gain                 | Parent impurity − weighted child impurity                  | [L5.4](#l5)   | Quinlan 1986     |
| <a name="g-val"></a>VAL           | Split purity                     | Size-weighted mean diversity of a cut's two sides          | [L5.4](#l5)   | Quinlan 1986     |
| <a name="g-cart"></a>CART         | Classification & regression tree | A tree whose every split is a named threshold              | [L6.2](#l6)   | Breiman 1984     |
| <a name="g-xai"></a>XAI           | Explainable AI                   | Models whose reasoning a human can audit                   | [L6.2](#l6)   | Breiman 1984     |
| <a name="g-prune"></a>PRUNE       | Tree pruning                     | Occam: smallest tree that still fits                       | [L6.4](#l6)   | Breiman 1984     |
| <a name="g-acq"></a>ACQ           | Acquisition function             | Rule for which unlabelled row to score next                | [L7.2](#l7)   | Settles 2009     |
| <a name="g-al"></a>AL             | Active learning                  | Model chooses its own next label                           | [L7.2](#l7)   | Settles 2009     |
| <a name="g-bo"></a>BO             | Bayesian optimization            | Fit a surrogate, sample where it promises most             | [L7.2](#l7)   | Settles 2009     |
| <a name="g-ts"></a>TS             | Thompson sampling                | Choose in proportion to chance-of-being-best               | [L7.3](#l7)   | Thompson 1933    |
| <a name="g-win"></a>WIN           | Win score                        | % of the way from median to best; capped [-100,100]        | [L8.1](#l8)   | —                |
| <a name="g-hold"></a>HOLD         | Holdout / cross-validation       | Never grade a model on rows it trained on                  | [L8.2](#l8)   | Stone 1974       |
| <a name="g-baseline"></a>BASELINE | Dumb baseline                    | Beat random, or admit you didn't                           | [L8.3](#l8)   | Dacrema 2019     |
| <a name="g-cohen"></a>COHEN       | Cohen's d                        | Mean gap in pooled-sd units; size, not p-value             | [L9.1](#l9)   | Cohen 1969       |
| <a name="g-clt"></a>CLT           | Central limit theorem            | Sample means scatter as σ/√n — the noise floor             | [L9.2](#l9)   | —                |
| <a name="g-ks"></a>KS             | Kolmogorov–Smirnov               | Largest gap between two CDFs                               | [L9.3](#l9)   | —                |
| <a name="g-cliff"></a>CLIFF       | Cliff's delta                    | Rank-imbalance effect size, 0..1                           | [L9.3](#l9)   | Cliff 1993       |
| <a name="g-same"></a>SAME         | Conservative sameness            | AND three effect-size tests before crying "different"      | [L9.3](#l9)   | —                |
| <a name="g-power"></a>POWER       | Statistical power                | Chance of catching a real effect; climbs with n            | [L9.4](#l9)   | —                |
| <a name="g-sk"></a>SK             | Scott-Knott ranking              | Group statistical ties into one rank                       | [L9.5](#l9)   | Scott 1974       |
| <a name="g-knn"></a>KNN           | k nearest neighbors              | The data is the model; ≤2× best error (1-NN)               | [L10.1](#l10) | Cover 1967       |
| <a name="g-anom"></a>ANOM         | Anomaly by distance              | Loneliest row = farthest from its nearest neighbor         | [L10.2](#l10) | Breunig 2000     |
| <a name="g-nb"></a>NB             | Naive Bayes                      | Argmax of per-feature likelihoods; right despite bad probs | [L10.3](#l10) | Domingos 1997    |
| <a name="g-km"></a>KM             | k-means                          | Assign to nearest centroid, recenter, repeat               | [L10.4](#l10) | Lloyd 1957       |
| <a name="g-kpp"></a>KPP           | k-means++                        | Seed centroids with chance ∝ distance²                     | [L10.4](#l10) | Arthur 2007      |
| <a name="g-dtlz"></a>DTLZ         | DTLZ benchmark suite             | Scalable multi-objective problems, known fronts            | [L10.5](#l10) | Deb 2005         |
| <a name="g-sbse"></a>SBSE         | Search-based SE                  | SE tasks as optimization problems                          | [L10.5](#l10) | Harman 2001      |
| <a name="g-ga"></a>GA             | Genetic algorithm                | Evolve a population: mutate, cross, keep dominators        | [L10.6](#l10) | Holland 1975     |
| <a name="g-de"></a>DE             | Differential evolution           | Kid = a + F·(b−c); replaces its parent if better           | [L10.6](#l10) | Storn 1997       |
| <a name="g-sa"></a>SA             | Simulated annealing              | Accept some bad moves, boldly early, rarely late           | [L10.6](#l10) | Kirkpatrick 1983 |
| <a name="g-ls"></a>LS             | Local search                     | Greedy (1+1): keep only improvements                       | [L10.6](#l10) | —                |

[contents](#contents)

---
