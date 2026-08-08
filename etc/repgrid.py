"""Repertory grid over the technologies behind seai26f topics.md.

Elements  = the 16 core technologies in the talk table.
Constructs = bipolar distinctions (rating 1 = left pole, 5 = right pole).
FOCUS-style display: grid reordered by hierarchical clustering,
dendrogram above elements, dendrogram beside constructs.
"""
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
from scipy.cluster.hierarchy import linkage, dendrogram, leaves_list

ELEMENTS = [
    "hill climbing", "simulated annealing", "genetic algorithm",
    "genetic programming", "genetic improvement", "NSGA-II", "IBEA",
    "MOEA/D", "NSGA-III", "MOSA/DynaMOSA", "MIO", "novelty search",
    "active learning (GALE)", "random proj. (SWAY)", "exact / ILP",
    "QAOA (quantum)", "LLM-driven", "classical+LLM (SNAP2)",
]

# (left pole, right pole)
CONSTRUCTS = [
    ("single solution",        "population of solutions"),
    ("one objective",          "many objectives"),
    ("heuristic, no guarantee","provably optimal"),
    ("cheap per evaluation",   "costly per evaluation"),
    ("needs 1000s of labels",  "frugal: 10s of labels"),
    ("domain-blind operators", "exploits domain priors"),
    ("fixed-length vectors",   "evolves structure/code"),
    ("converges (exploit)",    "diversifies (explore)"),
    ("model-free search",      "learns a data model"),
    ("1970s-80s vintage",      "2020s vintage"),
]

# rows = constructs, cols = elements; 1 = left pole ... 5 = right pole
G = np.array([
  # hc  sa  ga  gp  gi  ns2 ibe mod ns3 mos mio nov gal swy ilp qao llm sn2
  [  1,  1,  5,  5,  5,  5,  5,  5,  5,  5,  4,  5,  3,  3,  1,  2,  1,  3],  # single vs population
  [  1,  1,  2,  2,  2,  5,  5,  5,  5,  5,  5,  2,  4,  4,  2,  2,  3,  4],  # objectives
  [  1,  2,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  5,  2,  1,  1],  # guarantee
  [  1,  1,  2,  3,  4,  2,  3,  2,  2,  3,  3,  2,  2,  1,  2,  5,  5,  4],  # eval cost
  [  2,  2,  1,  1,  1,  1,  1,  1,  1,  2,  2,  1,  5,  5,  3,  2,  4,  4],  # label frugality
  [  1,  1,  1,  2,  4,  1,  1,  2,  2,  4,  4,  1,  2,  2,  4,  2,  5,  5],  # domain priors
  [  1,  1,  2,  5,  5,  2,  2,  2,  2,  3,  3,  3,  1,  1,  1,  1,  4,  3],  # representation
  [  1,  3,  3,  3,  2,  4,  3,  4,  4,  4,  3,  5,  3,  3,  1,  3,  2,  3],  # explore
  [  1,  1,  1,  1,  1,  1,  2,  2,  2,  1,  2,  1,  4,  3,  2,  1,  5,  5],  # learns model
  [  1,  1,  1,  2,  4,  3,  3,  3,  4,  4,  4,  3,  4,  4,  1,  5,  5,  5],  # vintage
], dtype=float)

assert G.shape == (len(CONSTRUCTS), len(ELEMENTS))

# FOCUS reorder: cluster elements (cols) and constructs (rows).
# Constructs may be reversed (a construct and its mirror carry the same
# distinction), so cluster rows on min(distance, reversed distance).
col_link = linkage(G.T, method="average", metric="cityblock")
col_order = leaves_list(col_link)

n = len(CONSTRUCTS)
D = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        d1 = np.abs(G[i] - G[j]).sum()
        d2 = np.abs(G[i] - (6 - G[j])).sum()
        D[i, j] = min(d1, d2)
from scipy.spatial.distance import squareform
row_link = linkage(squareform(D, checks=False), method="average")
row_order = leaves_list(row_link)

Gr = G[np.ix_(row_order, col_order)]
elems = [ELEMENTS[i] for i in col_order]
cons  = [CONSTRUCTS[i] for i in row_order]

# ---------------------------------------------------------------- figure
ink, ink2, grid_c = "#1a1f2e", "#5a6172", "#d9dde5"
cmap = LinearSegmentedColormap.from_list("seq", ["#f2f5fa", "#28527a"])

fig = plt.figure(figsize=(17, 9), facecolor="white")
gs = fig.add_gridspec(
    2, 4, width_ratios=[2.6, 10.5, 2.6, 1.5], height_ratios=[1.5, 6.4],
    left=0.005, right=0.995, top=0.90, bottom=0.17, wspace=0.02, hspace=0.02)

ax_top = fig.add_subplot(gs[0, 1])   # element dendrogram
ax_hm  = fig.add_subplot(gs[1, 1])   # grid
ax_rt  = fig.add_subplot(gs[1, 3])   # construct dendrogram
ax_lp  = fig.add_subplot(gs[1, 0])   # left poles
ax_rp  = fig.add_subplot(gs[1, 2])   # right poles

with plt.rc_context({"lines.linewidth": 1.2}):
    dendrogram(col_link, ax=ax_top, orientation="top", no_labels=True,
               color_threshold=0, above_threshold_color=ink2)
    dendrogram(row_link, ax=ax_rt, orientation="right", no_labels=True,
               color_threshold=0, above_threshold_color=ink2)
for ax in (ax_top, ax_rt, ax_lp, ax_rp):
    ax.set_axis_off()
ax_rt.invert_yaxis()                 # match heatmap row order (top -> bottom)

ax_hm.imshow(Gr, cmap=cmap, aspect="auto", vmin=1, vmax=5)
ax_hm.set_xticks(range(len(elems)))
ax_hm.set_xticklabels(elems, rotation=38, ha="right", fontsize=11, color=ink)
ax_hm.set_yticks([])
ax_hm.tick_params(length=0)
for s in ax_hm.spines.values():
    s.set_color(grid_c)
for i in range(Gr.shape[0]):
    for j in range(Gr.shape[1]):
        v = int(Gr[i, j])
        ax_hm.text(j, i, v, ha="center", va="center", fontsize=10.5,
                   color="white" if v >= 4 else ink)
ax_hm.set_xticks(np.arange(-.5, len(elems)), minor=True)
ax_hm.set_yticks(np.arange(-.5, len(cons)), minor=True)
ax_hm.grid(which="minor", color="white", linewidth=2)
ax_hm.tick_params(which="minor", length=0)

for k, (lp, rp) in enumerate(cons):
    y = 1 - (k + 0.5) / len(cons)
    ax_lp.text(0.97, y, lp + "  (1)", ha="right", va="center",
               fontsize=11, color=ink, transform=ax_lp.transAxes)
    ax_rp.text(0.03, y, "(5)  " + rp, ha="left", va="center",
               fontsize=11, color=ink, transform=ax_rp.transAxes)

fig.text(0.005, 0.965, "Repertory grid: the technology behind the tool talks",
         fontsize=17, fontweight="bold", color=ink)
fig.text(0.005, 0.925,
         "Elements = 18 optimizers from topics.md; constructs = bipolar poles, "
         "rated 1 (left pole) to 5 (right pole). "
         "Rows and columns FOCUS-clustered (average link; constructs matched up to pole reversal).",
         fontsize=11.5, color=ink2)
fig.text(0.995, 0.012, "seai26f docs/submit/topics.md · ratings are judgments: argue in class",
         fontsize=10, color=ink2, ha="right")

import os
out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "img", "repgrid.png")
fig.savefig(out, dpi=250)
print("wrote", out)
