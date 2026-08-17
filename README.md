<p align="center">
  <a href="https://github.com/txt/seai26f/blob/main/README.md"><img 
     src="https://img.shields.io/badge/Home-%23ff5733?style=flat-square&logo=home&logoColor=white" /></a>
  <a href="https://github.com/txt/seai26f/blob/main/docs/lect/policies.md"><img 
      src="https://img.shields.io/badge/Policies-%230055ff?style=flat-square&logo=openai&logoColor=white" /></a>
  <a href="#"><img
      src="https://img.shields.io/badge/Teams-%23ffd700?style=flat-square&logo=users&logoColor=white" /></a>
  <a href="https://moodle-courses2527.wolfware.ncsu.edu/course/view.php?id=11951&bp=s"><img 
      src="https://img.shields.io/badge/491%20Moodle-%23dc143c?style=flat-square&logo=moodle&logoColor=white" /></a>
  <a href="#"><img 
      src="https://img.shields.io/badge/591%20Moodle-%23f98012?style=flat-square&logo=moodle&logoColor=white" /></a>
  <a href="https://discord.gg/uQgTnGsfR"><img 
      src="https://img.shields.io/badge/Chat-%23008080?style=flat-square&logo=discord&logoColor=white" /></a>
  <a href="https://github.com/txt/seai26f/blob/main/LICENSE.md"><img 
      src="https://img.shields.io/badge/©%20timm%202026-%234b4b4b?style=flat-square&logoColor=white" /></a></p>
<h1 align="center">:cyclone: CSC491/591: SE for AI <br>NC State, Fall '26</h1>
<img src="https://raw.githubusercontent.com/txt/seai26f/refs/heads/main/etc/img/seai26f.png">

Mondays 4:30–7:15 PM, 2201 Engineering Building 3.

See [hello](https://txt.github.io/seai26f/hello.html) for the course intro, [policies](docs/lect/policies.md) for grading, [tools](docs/lect/tools.md) for the tool-talk menu, and the [talk signup sheet](https://docs.google.com/spreadsheets/d/1EsVadqssyJXaQPFjTVEfOs3Uv8DOQ0WyNlgTMcsoeBo/edit). Every lecture night (except exam nights) has a 1-mark in-class quiz (grads: only until the mid-term). Each tool-talk cell names its topic (tool:sa = simulated annealing, etc.) and links to that row of the [topics list](docs/lect/tools.md); groups (8 per cohort: 491 = 25 students, seven 3s and one 4; 591 = 23 students, seven 3s and one 2) sign up one group per topic. Tool talks are 30 minutes (aim for 25, leaving 5 for questions); grad task talks are 20 minutes (15 + 5). Night shape: about one hour of lecture, then one hour of tool talks (or, on Nov 16 and Nov 23, 90 minutes of task talks).

<div align=center>

| 📅 Date | 🎓 Lecture | 🛠️ submit <br>(due start of class) | 🎤 ugrad talks <br>(30 min each) | 🎤 grad talks <br>(tool 30 · task 20 min) | 🔍 Review |
|:-------------:|:----------:|:---------:|:---------:|:---------:|:---------:|
| Aug 17 | [hello](https://txt.github.io/seai26f/hello.html) + [tools](docs/lect/tools.md) + [Lua-101](src/ezr-lua/tut/lua101.md) | [eg0](https://txt.github.io/seai26f/ezr-eg0.html) | | | [w0](docs/review/w0.md) |
| Aug 24 | [columns](https://txt.github.io/seai26f/ezr-eg1.html) | [eg1](https://txt.github.io/seai26f/ezr-eg1.html) | | | |
| Aug 31 | dist | eg2 | [tool:ds](docs/lect/tools.md#ds) | [tool:hc](docs/lect/tools.md#hc) | |
| 🟩 ${\color{green}\textsf{Sep 07 — Labor Day, no class}}$ | | | | | |
| Sep 14 | cluster | eg3 | [tool:ga](docs/lect/tools.md#ga) | [tool:sa](docs/lect/tools.md#sa) | |
| Sep 21 | trees | eg4 | [tool:gp](docs/lect/tools.md#gp) | [tool:nsga2](docs/lect/tools.md#nsga2) | |
| Sep 28 | acquire | eg5 | [tool:nov](docs/lect/tools.md#nov) | [tool:ibea](docs/lect/tools.md#ibea) | |
| Oct 05 | stats | eg6 | [tool:moead](docs/lect/tools.md#moead) | [tool:al](docs/lect/tools.md#al) | |
| Oct 12 | 🟥 ${\color{#ff9999}\textsf{Mid-term exam}}$ | | no talks | no talks | |
| 🟩 ${\color{green}\textsf{Oct 19 — Fall break, no class}}$ | | | | | |
| Oct 26 | apps | eg7 · **[grad project](docs/submit/gproj.md) starts** | [tool:sway](docs/lect/tools.md#sway) | [tool:nsga3](docs/lect/tools.md#nsga3) | |
| Nov 02 | optimize | eg8 | [tool:qaoa](docs/lect/tools.md#qaoa) | [tool:mosa](docs/lect/tools.md#mosa) | |
| Nov 09 | dtlz | eg9 · **[grad project](docs/submit/gproj.md): initial** | [tool:port](docs/lect/tools.md#port) | [tool:llm](docs/lect/tools.md#llm) | |
| Nov 16 | | | | [taskA–D](docs/submit/gproj.md#the-task-talk-15-marks) | |
| Nov 23 | | | | [taskE–H](docs/submit/gproj.md#the-task-talk-15-marks) | |
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
| [ezr-eg0.lua](https://txt.github.io/seai26f/ezr-eg0.html) | boot: run, settings, read data | `--the` `--csv` `--repl`                                                 |
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

See [topics](docs/lect/tools.md): tool-talk subjects, 1976–2026,
every one a place these ideas get applied.

See also [MOOT](http://github.com/timm/moot)
