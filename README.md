<p align="center">
  <a href="https://github.com/txt/seai26f/blob/main/README.md"><img 
     src="https://img.shields.io/badge/Home-%23ff5733?style=flat-square&logo=home&logoColor=white" /></a>
  <a href="https://github.com/txt/seai26f/blob/main/docs/lect/policies.md"><img 
      src="https://img.shields.io/badge/Policies-%230055ff?style=flat-square&logo=openai&logoColor=white" /></a>
  <a href="#"><img
      src="https://img.shields.io/badge/Teams-%23ffd700?style=flat-square&logo=users&logoColor=white" /></a>
  <a href="https://moodle-courses2527.wolfware.ncsu.edu/course/view.php?id=11951"><img 
      src="https://img.shields.io/badge/Moodle-%23dc143c?style=flat-square&logo=moodle&logoColor=white" /></a>
  <a href="https://discord.gg/uQgTnGsfR"><img 
      src="https://img.shields.io/badge/Chat-%23008080?style=flat-square&logo=discord&logoColor=white" /></a>
  <a href="https://github.com/txt/seai26f/blob/main/LICENSE.md"><img 
      src="https://img.shields.io/badge/©%20timm%202026-%234b4b4b?style=flat-square&logoColor=white" /></a></p>
<h1 align="center">:cyclone: CSC491/591: SE for AI <br>NC State, Fall '26</h1>
<img src="https://raw.githubusercontent.com/txt/seai26f/refs/heads/main/etc/img/seai26f.png">

Mondays 4:30–7:15 PM, 2201 Engineering Building 3.

**Also:** [what?](https://txt.github.io/seai26f/what.html) |
[policies](docs/lect/policies.md) |
[ugrad project](docs/submit/uproj.md) |
[grad project](docs/submit/gproj.md) |
[Lua-101](src/ezr-lua/tut/lua101.md) |
[tools](docs/lect/tools.md)

See [what?](https://txt.github.io/seai26f/what.html) for the course intro, [policies](docs/lect/policies.md) for grading, [tools](docs/lect/tools.md) for the tool-talk menu, and the [talk signup sheet](https://docs.google.com/spreadsheets/d/1EsVadqssyJXaQPFjTVEfOs3Uv8DOQ0WyNlgTMcsoeBo/edit). Every lecture night (except exam nights) has a 1-mark in-class quiz (grads: only until the mid-term). Each tool-talk cell names its topic (tool:sa = simulated annealing, etc.) and links to that row of the [topics list](docs/submit/topics.md); groups (8 per cohort) sign up one group per topic. Talks are 20 minutes (aim for 15, leaving 5 for questions). Night shape: about one hour of lecture, then up to 90 minutes of student talks.

<div align=center>

| 📅 Date | 🎓 Lecture | 🛠️ submit <br>(due start of class) | 🎤 ugrad talks <br>(20 min each) | 🎤 grad talks <br>(20 min each) | 🔍 Review |
|:-------------:|:----------:|:---------:|:---------:|:---------:|:---------:|
| Aug 17 | [what?](https://txt.github.io/seai26f/what.html) | | | | [w0](docs/review/w0.md) |
| Aug 24 | [columns](https://txt.github.io/seai26f/ezr-eg1.html) | | | | [eg1](https://txt.github.io/seai26f/ezr-eg1.html) |
| Aug 31 | dist | | [tool:ds](docs/submit/topics.md#ds) | [tool:hc](docs/submit/topics.md#hc) | |
| 🟩 ${\color{green}\textsf{Sep 07 — Labor Day, no class}}$ | | | | | |
| Sep 14 | cluster | | [tool:ga](docs/submit/topics.md#ga) | [tool:sa](docs/submit/topics.md#sa) | |
| Sep 21 | trees | | [tool:gp](docs/submit/topics.md#gp) | [tool:nsga2](docs/submit/topics.md#nsga2) | |
| Sep 28 | acquire | | [tool:nov](docs/submit/topics.md#nov) | [tool:ibea](docs/submit/topics.md#ibea) | |
| Oct 05 | stats | | [tool:moead](docs/submit/topics.md#moead) | [tool:al](docs/submit/topics.md#al) | |
| Oct 12 | 🟥 ${\color{#ff9999}\textsf{Mid-term exam}}$ | | no talks | no talks | |
| 🟩 ${\color{green}\textsf{Oct 19 — Fall break, no class}}$ | | | | | |
| Oct 26 | apps | **[grad project](docs/submit/gproj.md) starts** | [tool:sway](docs/submit/topics.md#sway) | [tool:nsga3](docs/submit/topics.md#nsga3) | |
| Nov 02 | optimize | | [tool:qaoa](docs/submit/topics.md#qaoa) | [tool:mosa](docs/submit/topics.md#mosa) | |
| Nov 09 | dtlz | **[grad project](docs/submit/gproj.md): initial** | [tool:port](docs/submit/topics.md#port) | [tool:llm](docs/submit/topics.md#llm) | |
| Nov 16 | | | | taskA–D | |
| Nov 23 | | | | taskE–H | |
| Nov 30 | 🟥 ${\color{#ff9999}\textsf{Final exam (491 only, 1 hr)}}$ | **[grad project](docs/submit/gproj.md): final** · **[ugrad project](docs/submit/uproj.md)** | | | |
</div>

## The demos, week by week

The demos of `ezr-eg.lua`, `ezr-apps.lua` and `ezr-dtlz.lua`
are split into ten weekly files, `src/ezr-lua/ezr-eg0.lua` to
`ezr-eg9.lua`, sorted simplest to hardest. Each file is a
tutorial and a test suite at once: `--egs` lists that week's
demos, `--all` runs them (want "failures: 0"), and each file
ends with exercises. The later weeks look bigger, but each of
their demos is short application code reusing machinery from
the earlier weeks, so the reading load stays flat.

| file                                                      | theme                          | egs                                                                      |
| --------------------------------------------------------- | ------------------------------ | ------------------------------------------------------------------------ |
| ezr-eg0.lua                                               | boot: run, settings, read data | `--the` `--csv` `--repl`                                                 |
| [ezr-eg1.lua](https://txt.github.io/seai26f/ezr-eg1.html) | columns, streaming, forgetting | `--col` `--without` `--sub`                                              |
| ezr-eg2.lua                                               | distance & gap-to-heaven       | `--distx` `--disty` `--laws`                                             |
| ezr-eg3.lua                                               | clustering by poles            | `--half` `--node`                                                        |
| ezr-eg4.lua                                               | cuts, trees, XAI               | `--cuts` `--tree` `--show`                                               |
| ezr-eg5.lua                                               | active learning + holdout rig  | `--acquire` `--holdout` `--holdouts`                                     |
| ezr-eg6.lua                                               | statistics                     | `--same` `--ranks`                                                       |
| ezr-eg7.lua                                               | apps: predict, guard, group    | `--knn` `--detect` `--nb` `--kmeans` `--kpp`                             |
| ezr-eg8.lua                                               | classic optimizers             | `--dominate` `--ga` `--de` `--sa` `--ls` `--race`                        |
| ezr-eg9.lua                                               | DTLZ: labels cost money        | `--fronts` `--label` `--models` `--pure` `--why` `--generalize` `--wins` |

## Applications

See [topics](docs/submit/topics.md): tool-talk subjects, 1976–2026,
every one a place these ideas get applied.

See also [MOOT](http://github.com/timm/moot)
