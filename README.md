# Aim of this repository

This repository shows how to use CI in teaching settings, such as introductory courses with R. In this scenario, correcting is implemented for tasks during the semester (not for final exams). The use of CI helps to give students continuous feedback (or at least a chance of feedback without having too much weight on lecturers). 

In order to use this scenario, you should have intermediate knowledge about the following parts:


- [Continuous Integration](https://en.wikipedia.org/wiki/Continuous_integration)

- [Test cases](https://en.wikipedia.org/wiki/Test_case) 

- [gitlab runner](https://docs.gitlab.com/runner/)

## Scenario
We tested this in an introductory R course with BA students. The *continuous integration* should help students test if they achieved correct solutions in the lab tasks, and it should enable students to test their scripts regardless of the availability of the lecturer and teaching assistants. Furthermore, students should gain insights into the process of programming (repetitive steps, controlling/checking, troubleshooting). 

Most important, R is object-based, and this testing compares created objects against a final model solution.

# Steps to use CI

## Setting up R
In this example, we run unit tests and use the package [testthat](https://testthat.r-lib.org). With this package, users can build test scenarios used in the CI later on. We restrict the use to the most straightforward implementation: we will compare objects that students need to build and check if these objects were built correctly (as intended by the tasks).

In the following example, we have two subtasks that students should do in their script:

1a. Build an object called `math` that inherits a single value of 6 (as a result of any calculation).

1b. Build a second object called `math2` that inherits a single value of 36 (which should result from a calculation of the object `math`).

Be aware that we only test the subtasks in this simple model except for the brackets. 

In order to build different stages and indicate students where they failed, we create a single test script for each task/subtask. In this example, we created files called `test1a.R` and `test1b.R`.

Each script inherits:

1. loading students script

2. loading library *testthat* 

3. testing students' objects against the aimed result.


**Solution for task 1**
```r
source(
  "./stud-solution.R",
  chdir = TRUE
)

library(testthat)
local_edition(3)
math_sol <- 6

test_that("correct math object", {
  expect_equal(
  math,   # students' object
  math_sol    # solution object
  )
})
```

**Solution for task 2**
```r
source(
  "./stud-solution.R",
  chdir = TRUE
)

library(testthat)
local_edition(3)
math2_sol <- math * 6


test_that("correct math2 object?", {
  expect_equal(
  math2,     # students' object
  math2_sol   # solution object  
  )
})
``` 

The example above is the easiest way (comparing objects that should inherit the same). However, the package *testthat* offers other test functions, too. As mentioned above, we do not test, if they used a calculation to create their objects (we just tested the final value). You can also compare other objects from linear regressions or ggplot.

As you can see in the solution script, the files uploaded by the students need to match the file's name in the script (here: *stud-solution.R*). Keep your students aware of this. If students name the file otherwise, the test will fail.

In order to not let students see the final solutions, we keep the solution files in another project which is not accessible by students (see below).


## Setting up gitlab
To use *continuous integration*, you need to have an available **gitlab runner** (so far not globally available at jlu-gitlab-distribution). Since our tasks are only minor, we used a private server, which will be used as **gitlab runner** (the data we used in this introductory course is a fictional data set, has limited size, and does not inherit sensitive data at all). If you want to know more about setting up the runner, follow [here](https://docs.gitlab.com/runner/).

If you have installed a gitlab runner, you can use a `.gitlab-ci.yaml`-file to configure the continuous integration. In our example, we wanted to make it available to students to test their solution against the model solution at any point in time, but only if they wanted to test it (so there is no automatic test, for example, if you make a new push). 

Our test course was structured as follows:
```
intro-r (main course)
├── course materials
│   └── ...
├── group 1
│   └── ...
├── ...
│   └── ...
└── group n
    ├── lab 1
    │     ├── gitlab-ci.yaml (ci integration)
    │     └── stud-solution.R (students' solution)
    ├── ...
    └── lab n
          ├── gitlab-ci.yaml (ci integration)
          └── stud-solution.R (students' solution)
```

In each group we created different projects for each lab task. In each lab task, we created the `gitlab-ci.yaml`-file, and students uploaded their solutions. If you have not heard about groups and subgroups in gitlab, you will find [help here](https://docs.gitlab.com/ee/user/group/subgroups/). We opted for subgroups since we also wanted to be able to clone all files at once with [gitlabber](https://github.com/ezbz/gitlabber).

Again, in this example, we just show the solution lab 1 subtask 1a and 1b. 

As mentioned above, we stored the solutions in a different project. For each (sub-)task, we created a single file to test the solutions consecutively. This also enables to show students which part of the lab tasks they failed.   

```
root project
├── lab 1
│   ├── test1a.R
│   ├── test1b.R
│   └── ...
├── lab 2
│   └── ...
├── ...
│   └── ...
└── lab n
    └── ...
```

We created a *CI*-Runner in each lab that tests tasks (or subtasks) against the model solution.

If you are not working on a single project, you need to set your runners as group runners under `Settings -> CI/CD -> Runners`. You need to activate *shared runners* for this group. If you use a structure like ours, you also have to do this setting in each subgroup and in each subgroup project.

### The runner instruction (yaml-file)
You create the instructions for the runner within the file: `.gitlab-ci.yaml`. 

This is an example runner-file for the mentioned scenario. Below, we go through the different blocks.
```yaml
image: rocker/tidyverse

workflow:
  rules:
    - if: '$CI_PIPELINE_SOURCE == "push"'
      when: never  # Prevent pipeline run for push event
    - when: always # Run pipeline for all other cases

variables:
  SCRIPTS_REPO: https://$SCRIPTS_USER:$SCRIPTS_TOKEN@gitlab.com/bpkleer/r-teaching/
before_script:
  - export SCRIPTS_DIR=$(mktemp -d)
  - git clone -q --depth 1 "$SCRIPTS_REPO" "$SCRIPTS_DIR"
    
stages:
  - build
  - check task 1

load packages:
  stage: build
  script: 
    - apt-get update
    - R -e 'install.packages(c("testthat"))'

task 1a:
  stage: check task 1
  script:
    - r $SCRIPTS_DIR/solutions/lab1/test_check1a.R
```

In the first block, we define that we use a docker-image with R and preloaded tidyverse on the server (you need to install [docker](https://www.docker.com/) on your server). This has the advantage that each run is in a single container on the server. However, this needs some time (most part of the runner in our examples).

```yaml
image: rocker/tidyverse
```

In the second block (*workflow*), we define when the pipeline starts. Usually, people opt to start on every push or merge. We decided against it since our students were new to git/gitlab, and we only had limited resources (private server). We opted for a solution that students need to manually start the pipeline from the browser.

```yaml
workflow:
  rules:
    - if: '$CI_PIPELINE_SOURCE == "push"'
      when: never  # Prevent pipeline run for push event
    - when: always # Run pipeline for all other cases
```

In the third block, we set global variables. This is needed since we stored the solutions in an outside repository, and we do not want students to access this outside repository.

```yaml
variables:
  SCRIPTS_REPO: https://$SCRIPTS_USER:$SCRIPTS_TOKEN@gitlab.com/bpkleer/r-teaching/
before_script:
  - export SCRIPTS_DIR=$(mktemp -d)
  - git clone -q --depth 1 "$SCRIPTS_REPO" "$SCRIPTS_DIR"
```

We saved the solutions in a private gitlab.com-Repo, and access to this repository is not public. To access the folder, we created a token on gitlab.com. We saved the created token (name and token itself) on JLU-gitlab in each lab project of a subgroup under `Settings -> CI/CD -> Variables`. Students cannot access the settings in the lab projects (they are only developers, not maintainers). We can clone the solution repository into the container and compare students' solutions against the model solution with this information.

The next block structures the `stages` of the pipeline. This simple example divides only two stages: `build` and `check task 1`. In other cases, we created a stage for every task (which inherits the subtasks then).

```yaml
stages:
  - build
  - check task 1
```

We have a build stage, mainly used to build the container, load the solutions, and load necessary packages. 

Following, each step will be defined in the *yaml*-file:

```
load packages:
  stage: build
  script: 
    - apt-get update
    - R -e 'install.packages(c("testthat"))'
```

And then, we add two additional tasks to check the subtask 1a and 1b, both inherited in stage *check task 1*:
```yaml
task 1a:
  stage: check task 1
  script:
    - r $SCRIPTS_DIR/solutions/lab1/test_check1a.R
    
task 1b:
  stage: check task 1
  script:
    - r $SCRIPTS_DIR/solutions/lab1/test_check1b.R
```

For each subtask, we define that it belongs to stage check task 1, and we load the specific solution script from the cloned solution repository.

And that's it!

## How the pipeline looks like for students
After initiating a pipeline (in each project under `CI/CD -> Pipeline -> Run pipeline`), students can follow the development (if they want to):

![Running pipeline](./assets/pictures/pipeline.png)

If the runner is finished, the result will be displayed. In the pass case like this:

![Passed pipeline](./assets/pictures/pipeline-passed.png)

If the pipeline fails, students will see where it failed:

![Failed pipeline](./assets/pictures/pipeline-failed.png)

By clicking on the failed task, they get into a console window and see the result of the test:

![Failed pipeline result](./assets/pictures/pipeline-failed2.png)

Within the package *testthat*, you can choose between different versions (mostly 2 and 3), whereby package 3 prints precisely why the test failed (see screenshot above). As a result, students know that their object did not equal 36 (so they should work on the calculation of 36 and test it again).
