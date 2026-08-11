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

# Course Policies

| About | Notes |
|------:|-----|
|What   | Special Topics in Computer Science: SE for AI |
|Term   | 2026 Fall Term |
|Subject / Catalog Nbr / Section | CSC 491, Section 005 (ugrad) and CSC 591, Section 005 (grad) |
| When  | Mon 4:30PM - 7:15PM |
|Where  | 02201 Engineering Building 3 |
|Discord server| [https://discord.gg/uQgTnGsfR](https://discord.gg/uQgTnGsfR) |
|Who    | Lecturer: [Prof Tim Menzies](http://timm.fyi), <timm@ieee.org> |
|Office hours | By appointment (office: 3304 Engineering Building 2) |
|Course website | [https://github.com/txt/seai26f](https://github.com/txt/seai26f) |
|Credit hours | 3 |
|Textbook | None |
|Auditing | Not permitted |

## Course Description

From the NC State course catalog:

> **CSC 491/591 — Special Topics in Computer Science.** Topics of current
> interest in computer science not covered in existing courses. Each special
> topics course will have one or more prerequisites from the Computer Science
> core courses. Credits and content are determined by the faculty member in
> consultation with the Director of Undergraduate Programs and the CSC UGCC.
> Students may receive credit multiple times for this course if a different
> topic is taught.

This section (005) covers **Software Engineering for AI**: the principles,
tools, and processes needed to build, test, deploy, and maintain software
systems that include AI components.

The schedule of activities on the course README is subject to change,
with appropriate notification to students.

## Student Learning Outcomes

This course is about generating and assessing alternate technologies for
AI: given a task now handed by default to a large language model, find,
build, and fairly measure the cheaper, faster, more explainable
alternatives. Upon completion of this course, students will be able to:

1. Given an SE task, generate alternative AI technologies for it — LLMs,
   optimizers, active learners, retrieval, symbolic methods — and defend
   the choice with measured cost and quality.
2. Benchmark an AI method against at least one cheaper baseline, over
   repeated runs, reporting variance and honest negative results.
3. Learn a new tool from its documentation and originating paper alone,
   and demonstrate it running.
4. Work with AI assistants critically: state measurable claims (metric,
   threshold, baseline), verify outputs against evidence, and catch and
   document errors.

CSC 591 students will additionally be able to:

5. Pre-register and execute a project evaluation: a claim, a runnable
   instrument, and honest reporting of what failed.
6. Communicate research clearly and professionally, in both written and
   oral forms, as part of a team project.

## Student Performance Assessment

Weekly homeworkds are score 0-1 for "you tried" and "you did try enough". Students will
arrive in class with that homework printed on one side of a piece of papeer marked only with the alst 4 digits
of the student id numbers. 

Weekly in-class quizzes reward attendance. Weeklies start at the first minute of class (do not be late). 
During the weeklies, use of any electronic device is banned.
In the weeklies, you will be given practice questions
of the kind you will see in exams. Weeklies will be answered on the back of the homework sheet. 

Talks are delivered in person by one person and all other members of that group are required to stand on stage
behding their presenter.
See the schedule on the course [README](https://github.com/txt/seai26f/blob/main/README.md).
Each cohort is graded out of 100 marks.

| Component                             |                  CSC 491 (ugrad)                   |                               CSC 591 (grad)                               |
| ------------------------------------- | :------------------------------------------------: | :------------------------------------------------------------------------: |
| Weekly in-class quizzes (1 mark each) | 13 (one per lecture night; none on mid-term night) |                      7 (quizzes stop after mid-term)                       |
| Group tool talk                       |                         15                         |                                     15                                     |
| Task talk                             |                         —                          |                                     15                                     |
| Mid-term                              |                         24                         |                                     24                                     |
| Project                               |  24 ([shrinking-code demos](../submit/uproj.md))   | 39 (six-week team [research project](../submit/gproj.md), Oct 26 – Nov 30) |
| Final exam                            |                         24                         |                      — (project carries that weight)                       |
| **Total**                             |                      **100**                       |                                  **100**                                   |

The grad project must be far more
creative than the undergrad one:

- undergrads execute a defined corpus;
-  grads must invent the problem, pre-register its eval, and defend the
results. 

For grad students
- the  project's initial deliverable (5 marks), two weeks in (Mon
Nov 9), must show *something working* — a runnable slice plus the
pre-registered eval: claim (metric, threshold, baseline) and instrument
demonstrated on sample or synthetic data. 
- The final project deliverable (34
marks), on the last class (Mon Nov 30), reports results against that
pre-registered claim; real data earns the top of the range, and a failed
claim with a recorded decision (persevere, re-plan, descope) loses
nothing — an unrun or hidden eval does.
- Task talks (30 minutes, one per
grad group) 

For all students:
- Tool talks (30 minutes, every group) run Sep
14 to Nov 9, two or three per night.

**Attendance and participation:** Classes are in person. The weekly in-class
quizzes can only be taken in class; a missed quiz scores zero unless the absence
is excused under NCSU REG 02.20.03 (Attendance Regulations), in which case a
makeup will be arranged. Talks must be delivered in person at the scheduled
slot.

**Late work:** Late submissions lose one mark per day late (weekends count as
one day).

**Grading scale:**

    A+ (97-100),  A (93-96),   A- (90-92)
    B+ (87-89),   B (83-86),   B- (80-82)
    C+ (77-79),   C (73-76),   C- (70-72)
    D+ (67-69),   D (63-66),   D- (60-62)
    F  (below 60)

## Additional Required Cost-Bearing Course Materials

This course engages diverse scholarly perspectives to develop critical
thinking, analysis, and debate; inclusion of a reading does not imply
endorsement.

None. There is no required textbook and there are no course-related fees.

A laptop computer is required in each lecture. NC State University Libraries
offers Technology Lending, where many devices are available to borrow for a
7-day period, and computer labs are available in various locations around
campus for student use.

## Communication

- For private queries, use <timm@ieee.org>.
- For most queries, use our [Discord](https://discord.gg/uQgTnGsfR). It is
  each student's responsibility to join the class Discord server; all class
  communication from staff to students will be via that server.
- Expect a response within two business days (i.e. not over the weekend).
  Messages sent outside office hours need not be answered until the next
  working day.
- Always include a descriptive, specific but concise subject, your course
  number and section, and adequate context. Use your NC State email account.
- Any temporary change in course modality due to unforeseen circumstances
  will be announced via both Moodle and the class Discord.
- Remember: all your posts here are public. Always be professional and polite.

## Academic Integrity

Students are expected to do their own work on tests and exams. For talks and
projects, use of AI assistants and other tools is permitted and encouraged --
this is a course about engineering with AI -- but all submitted work must
disclose what tools were used and how, and students must be able to explain
everything they submit.

Students are bound by the Pack Pledge: "I have neither given nor received
unauthorized aid on this test or assignment."

Violations of academic integrity will be handled in accordance with the
Student Discipline Procedures (NCSU REG 11.35.02).

## Accommodations

Reasonable accommodations will be made for students with verifiable
disabilities. To take advantage of available accommodations, students must
register with the NC State University Disability Resource Office. For more
information on NC State's policy on working with students with disabilities,
please see the Academic Accommodations for Students with Disabilities
Regulation (NCSU REG 02.20.01).

## Student Mental Health

As a student, you may experience a range of personal issues that can impede
learning. The Counseling Center at NC State offers confidential mental health
services for full-time NC State students, including same-day emergency
services. A full overview of campus wellness resources can be found on the
[WolfPack Wellness website](https://wellness.ncsu.edu). Please do not hesitate
to get connected early for the support you need to be successful.

## Digital Course Components and Recording

Course materials and student work live in public GitHub repositories and the
class Discord. Students may be required to disclose personally identifiable
information to other students in the course, via digital tools, where relevant
to the course. All students are expected to respect the privacy of each other
by not sharing or using such information outside the scope of the course.

Lectures may be recorded. Unauthorized audio or video recordings and
photographs of class lectures or discussions are prohibited; unauthorized
recording and distribution may violate federal privacy laws (FERPA),
copyright laws, and the university's Code of Student Conduct.

## University Policies

Students are responsible for reviewing the NC State University Policies,
Rules, and Regulations (PRRs), which pertain to their course rights and
responsibilities, including, but not limited to:

- POL 04.25.05 Equal Opportunity and Non-Discrimination Policy Statement
- REG 02.20.01 Academic Accommodations for Students with Disabilities
- POL 11.35.01 Student Conduct
- REG 11.35.05 Code of Student Conduct
- REG 11.35.02 Student Discipline Procedures
- REG 02.20.03 Attendance Regulations
- REG 02.50.03 Grades and Grade Point Average
- REG 02.20.15 Credit-Only Courses
- REG 02.20.04 Audits
- REG 08.00.11 Online Course Material Host Requirements
